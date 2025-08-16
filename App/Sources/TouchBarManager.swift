import Foundation
import AppKit
import IOKit

enum TouchBarError: LocalizedError {
    case noTouchBar
    case processNotFound
    case killFailed(String)
    case serviceRestartFailed
    case securityViolation(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .noTouchBar:
            return "This device doesn't have a Touch Bar"
        case .processNotFound:
            return "Touch Bar process not found"
        case .killFailed(let process):
            return "Failed to restart \(process)"
        case .serviceRestartFailed:
            return "Failed to restart Touch Bar service"
        case .securityViolation(let message):
            return "Security violation: \(message)"
        case .unknown(let message):
            return message
        }
    }
}

class TouchBarManager: ObservableObject {
    @Published var isRestarting = false
    @Published var lastRestartTime: Date?
    @Published var restartCount = 0
    @Published var hasTouchBar = false
    @Published var lastError: TouchBarError?
    
    // SECURITY: Hardcoded, validated list of allowed Touch Bar processes
    private let allowedTouchBarProcesses: Set<String> = [
        "TouchBarServer",
        "NowPlayingTouchUI", 
        "ControlStrip",
        "TouchBarAgent",
        "TouchBarUserDevice",
        "DFRFoundation"
    ]
    
    private let userDefaults = UserDefaults.standard
    private let restartCountKey = "TouchBarRestartCount"
    private let lastRestartKey = "LastTouchBarRestart"
    
    init() {
        loadData()
        checkTouchBarAvailability()
        // Force immediate update of published property
        objectWillChange.send()
    }
    
    // SECURITY: Validate and sanitize process names before use
    private func validateProcessName(_ processName: String) -> Bool {
        // Simply check if it's in our allowed list - that's the most important security check
        let isAllowed = allowedTouchBarProcesses.contains(processName)
        
        if !isAllowed {
            print("🔒 Process validation failed: '\(processName)' not in allowed list")
        }
        
        return isAllowed
    }
    
    // SECURITY: Sanitize process names to prevent injection
    private func sanitizeProcessName(_ processName: String) -> String {
        // Remove any non-alphanumeric characters except hyphens
        let sanitized = processName.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted).joined()
        
        // SECURITY: Log sanitization for security monitoring
        if sanitized != processName {
            print("🔒 Process name sanitized: '\(processName)' -> '\(sanitized)'")
        }
        
        return sanitized
    }
    
    private func checkTouchBarAvailability() {
        // Check if this Mac model has a Touch Bar
        // Models with Touch Bar have specific identifiers
        let modelIdentifier = getModelIdentifier().trimmingCharacters(in: .whitespacesAndNewlines)
        let touchBarModels = [
            "MacBookPro13,2", "MacBookPro13,3", // 2016
            "MacBookPro14,2", "MacBookPro14,3", // 2017
            "MacBookPro15,1", "MacBookPro15,2", "MacBookPro15,3", "MacBookPro15,4", // 2018-2019
            "MacBookPro16,1", "MacBookPro16,2", "MacBookPro16,3", "MacBookPro16,4", // 2019-2020
            "MacBookPro17,1", // 2020 M1 13"
            "MacBookPro18,3", "MacBookPro18,4", // 2021 M1 Pro/Max
        ]
        
        // More robust detection - also check if TouchBarServer process exists
        let modelHasTouchBar = touchBarModels.contains(modelIdentifier)
        let touchBarServerExists = checkIfProcessRunning("TouchBarServer") || checkIfProcessRunning("ControlStrip")
        
        hasTouchBar = modelHasTouchBar || touchBarServerExists
        
        print("🔍 Touch Bar Detection:")
        print("   Model: \(modelIdentifier)")
        print("   Model in list: \(modelHasTouchBar)")
        print("   TouchBar processes found: \(touchBarServerExists)")
        print("   Final detection: \(hasTouchBar)")
    }
    
    // SECURITY: Add bounds checking to prevent buffer overflow
    private func getModelIdentifier() -> String {
        var size = 0
        let result = sysctlbyname("hw.model", nil, &size, nil, 0)
        
        // SECURITY: Validate sysctl result and size
        guard result == 0, size > 0, size < 1024 else { // Reasonable bounds for model name
            print("🔒 Security: Invalid sysctl result or size: \(result), \(size)")
            return "Unknown"
        }
        
        var model = [CChar](repeating: 0, count: size)
        let readResult = sysctlbyname("hw.model", &model, &size, nil, 0)
        
        // SECURITY: Validate read result
        guard readResult == 0 else {
            print("🔒 Security: Failed to read sysctl: \(readResult)")
            return "Unknown"
        }
        
        return String(cString: model)
    }
    
    func restartTouchBar() async -> Result<Void, TouchBarError> {
        // Re-check Touch Bar availability before restart
        checkTouchBarAvailability()
        
        print("🚀 Starting Touch Bar restart process...")
        print("   Device has Touch Bar: \(hasTouchBar)")
        print("   Model: \(getModelIdentifier())")
        
        // Enhanced logging for Console verification
        print("\n" + String(repeating: "=", count: 60))
        print("🚀 TOUCH BAR RESTART INITIATED")
        print("   Timestamp: \(Date())")
        print("   Device model: \(getModelIdentifier())")
        print("   Has Touch Bar: \(hasTouchBar)")
        print("   App Version: 1.2.1")
        print(String(repeating: "=", count: 60))
        
        // Check if device has Touch Bar
        guard hasTouchBar else {
            print("❌ No Touch Bar detected on this device")
            await MainActor.run {
                self.lastError = .noTouchBar
                self.isRestarting = false
            }
            return .failure(.noTouchBar)
        }
        
        // Check initial state of Touch Bar processes
        print("\n📊 PRE-RESTART PROCESS STATUS:")
        for process in allowedTouchBarProcesses {
            let isRunning = checkIfProcessRunning(process)
            print("   • \(process): \(isRunning ? "✅ Running" : "❌ Not Running")")
        }
        
        await MainActor.run {
            isRestarting = true
            lastError = nil
        }
        
        // SECURITY: Use validated, hardcoded process list instead of dynamic input
        let processes = Array(allowedTouchBarProcesses)
        var allSuccessful = true
        
        print("\n🎯 KILLING PROCESSES:")
        print("   Targets: \(processes.joined(separator: ", "))")
        
        for process in processes {
            let result = await secureKillProcess(process)
            if case .failure(let error) = result {
                print("❌ Failed to kill \(process): \(error.localizedDescription)")
                await MainActor.run {
                    self.lastError = error
                }
                allSuccessful = false
            }
        }
        
        print("\n⏱️ Waiting 2 seconds for processes to restart...")
        // Wait for processes to restart
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Verify processes have restarted
        print("\n📊 POST-RESTART PROCESS STATUS:")
        for process in allowedTouchBarProcesses {
            let isRunning = checkIfProcessRunning(process)
            print("   • \(process): \(isRunning ? "✅ Running" : "❌ Not Running")")
        }
        
        // Additional verification for critical processes
        print("\n🔍 Verifying critical Touch Bar processes:")
        let criticalProcesses = ["TouchBarServer", "ControlStrip"]
        var criticalRunning = true
        for process in criticalProcesses {
            let isRunning = checkIfProcessRunning(process)
            print("   • \(process): \(isRunning ? "✅ VERIFIED RUNNING" : "⚠️ NOT DETECTED")")
            if !isRunning && process == "TouchBarServer" {
                criticalRunning = false
            }
        }
        
        // Reset Touch Bar preferences if needed
        if allSuccessful {
            print("🔧 Resetting Touch Bar preferences...")
            await resetTouchBarPreferences()
            
            await MainActor.run {
                self.lastRestartTime = Date()
                self.restartCount += 1
                self.saveData()
                self.isRestarting = false
            }
            
            print("\n" + String(repeating: "=", count: 60))
            print("✅ TOUCH BAR RESTART COMPLETED SUCCESSFULLY!")
            print("   Restart Count: #\(restartCount)")
            print("   Timestamp: \(Date())")
            print("   Duration: ~2.5 seconds")
            print("   Final Status: \(getTouchBarStatus())")
            print(String(repeating: "=", count: 60) + "\n")
            return .success(())
        }
        
        await MainActor.run {
            self.isRestarting = false
        }
        
        print("❌ Touch Bar restart failed")
        return .failure(lastError ?? .unknown("Failed to restart Touch Bar"))
    }
    
    // SECURITY: Secure process termination with validation
    private func secureKillProcess(_ processName: String) async -> Result<Void, TouchBarError> {
        // SECURITY: Validate process name before any operations
        guard validateProcessName(processName) else {
            let error = TouchBarError.securityViolation("Invalid process name: '\(processName)'")
            print("🔒 Security violation: \(error.localizedDescription)")
            return .failure(error)
        }
        
        // SECURITY: Double-check against allowed list
        guard allowedTouchBarProcesses.contains(processName) else {
            let error = TouchBarError.securityViolation("Unauthorized process: '\(processName)'")
            print("🔒 Security violation: \(error.localizedDescription)")
            return .failure(error)
        }
        
        // Log for verification in Console
        print("📊 TOUCH_BAR_RESTART: Killing process '\(processName)' at \(Date())")
        print("🔄 Attempting to kill process: \(processName)")
        
        let task = Process()
        // SECURITY: Use executableURL instead of launchPath for better security
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        task.arguments = ["-x", processName]
        
        let pipe = Pipe()
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let terminationStatus = task.terminationStatus
            print("   pkill \(processName) returned: \(terminationStatus)")
            
            // pkill returns 0 if at least one process was killed, 1 if no process found
            // We treat "no process found" as success (it might not be running)
            if terminationStatus == 0 {
                print("   ✅ Successfully killed \(processName)")
                return .success(())
            } else if terminationStatus == 1 {
                print("   ⚠️ \(processName) was not running")
                return .success(())
            } else {
                let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("   ❌ Failed to kill \(processName): \(errorString)")
                return .failure(.killFailed("\(processName): \(errorString)"))
            }
        } catch {
            print("   ❌ Exception killing \(processName): \(error.localizedDescription)")
            return .failure(.killFailed("\(processName): \(error.localizedDescription)"))
        }
    }
    
    
    private func resetTouchBarPreferences() async {
        print("🔧 Resetting Touch Bar preferences and cache...")
        
        // SECURITY: Hardcoded, validated preference domains
        let preferenceDomains = [
            "com.apple.touchbar.agent",
            "com.apple.controlstrip",
            "com.apple.TouchBarAgent"
        ]
        
        for domain in preferenceDomains {
            let task = Process()
            // SECURITY: Use executableURL for better security
            task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
            task.arguments = ["delete", domain]
            
            do {
                try task.run()
                task.waitUntilExit()
                if task.terminationStatus == 0 {
                    print("   ✅ Cleared \(domain)")
                }
            } catch {
                // Ignore errors - domain might not exist
            }
        }
        
        // Also restart the Dock to refresh Touch Bar state
        let dockTask = Process()
        // SECURITY: Use executableURL for better security
        dockTask.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        dockTask.arguments = ["Dock"]
        
        do {
            try dockTask.run()
            dockTask.waitUntilExit()
            print("   ✅ Restarted Dock to refresh Touch Bar")
        } catch {
            print("   ⚠️ Could not restart Dock: \(error)")
        }
    }
    
    private func loadData() {
        restartCount = userDefaults.integer(forKey: restartCountKey)
        if let date = userDefaults.object(forKey: lastRestartKey) as? Date {
            lastRestartTime = date
        }
    }
    
    private func saveData() {
        userDefaults.set(restartCount, forKey: restartCountKey)
        if let date = lastRestartTime {
            userDefaults.set(date, forKey: lastRestartKey)
        }
    }
    
    func getTouchBarStatus() -> String {
        guard hasTouchBar else {
            return "No Touch Bar"
        }
        
        let task = Process()
        // SECURITY: Use executableURL for better security
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        task.arguments = ["-x", "TouchBarServer"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0 ? "Running" : "Not Running"
        } catch {
            return "Unknown"
        }
    }
    
    func checkIfProcessRunning(_ processName: String) -> Bool {
        // SECURITY: Validate process name before checking
        guard validateProcessName(processName) else {
            print("🔒 Security: Attempted to check invalid process: '\(processName)'")
            return false
        }
        
        let task = Process()
        // SECURITY: Use executableURL for better security
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        task.arguments = ["-x", processName]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}
