import Foundation
import AppKit
import IOKit

enum TouchBarError: LocalizedError {
    case noTouchBar
    case processNotFound
    case killFailed(String)
    case serviceRestartFailed
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
    
    private let userDefaults = UserDefaults.standard
    private let restartCountKey = "TouchBarRestartCount"
    private let lastRestartKey = "LastTouchBarRestart"
    
    init() {
        loadData()
        checkTouchBarAvailability()
        // Force immediate update of published property
        objectWillChange.send()
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
    
    private func getModelIdentifier() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    func restartTouchBar() async -> Result<Void, TouchBarError> {
        // Re-check Touch Bar availability before restart
        checkTouchBarAvailability()
        
        print("🚀 Starting Touch Bar restart process...")
        print("   Device has Touch Bar: \(hasTouchBar)")
        print("   Model: \(getModelIdentifier())")
        
        // Check if device has Touch Bar
        guard hasTouchBar else {
            print("❌ No Touch Bar detected on this device")
            await MainActor.run {
                self.lastError = .noTouchBar
                self.isRestarting = false
            }
            return .failure(.noTouchBar)
        }
        
        await MainActor.run {
            isRestarting = true
            lastError = nil
        }
        
        // Kill Touch Bar related processes
        let processes = ["TouchBarServer", "NowPlayingTouchUI", "ControlStrip"]
        var allSuccessful = true
        
        print("🎯 Targeting processes: \(processes.joined(separator: ", "))")
        
        for process in processes {
            let result = await killProcess(named: process)
            if case .failure(let error) = result {
                print("❌ Failed to kill \(process): \(error.localizedDescription)")
                await MainActor.run {
                    self.lastError = error
                }
                allSuccessful = false
            }
        }
        
        print("⏱️ Waiting 2 seconds for processes to restart...")
        // Wait for processes to restart
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Verify processes have restarted
        print("🔍 Verifying Touch Bar processes have restarted...")
        let verificationProcesses = ["TouchBarServer"]
        for process in verificationProcesses {
            let isRunning = checkIfProcessRunning(process)
            print("   \(process): \(isRunning ? "✅ Running" : "❌ Not running")")
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
            
            print("✅ Touch Bar restart completed successfully! (Restart #\(restartCount))")
            print("📊 Final status: \(getTouchBarStatus())")
            return .success(())
        }
        
        await MainActor.run {
            self.isRestarting = false
        }
        
        print("❌ Touch Bar restart failed")
        return .failure(lastError ?? .unknown("Failed to restart Touch Bar"))
    }
    
    private func killProcess(named processName: String) async -> Result<Void, TouchBarError> {
        print("🔄 Attempting to kill process: \(processName)")
        
        let task = Process()
        task.launchPath = "/usr/bin/pkill"
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
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["delete", "com.apple.touchbar.agent"]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Failed to reset Touch Bar preferences: \(error)")
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
        task.launchPath = "/usr/bin/pgrep"
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
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
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
