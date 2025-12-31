import Foundation
import AppKit
import IOKit

// MARK: - Process Restart Status Types

/// Status of a single process restart attempt
enum ProcessRestartStatus: Equatable {
    case success           // Process was killed and restarted successfully
    case notRunning        // Process was not running (OK - nothing to restart)
    case permissionDenied  // Could not kill (likely root process, needs admin)
    case failed(String)    // Other failure with message
}

/// Result of attempting to restart a single process
struct ProcessRestartResult {
    let processName: String
    let status: ProcessRestartStatus
    let previousPID: Int?
    let newPID: Int?
}

/// Combined result of restarting all Touch Bar processes
struct TouchBarRestartResult {
    let results: [ProcessRestartResult]
    let overallSuccess: Bool
    let needsAdmin: Bool

    /// Processes that need admin privileges to restart
    var processesNeedingAdmin: [String] {
        results.filter { $0.status == .permissionDenied }.map { $0.processName }
    }

    /// Processes that successfully restarted
    var successfulProcesses: [String] {
        results.filter { $0.status == .success || $0.status == .notRunning }.map { $0.processName }
    }

    /// Processes that failed for reasons other than permissions
    var failedProcesses: [String] {
        results.filter {
            if case .failed = $0.status { return true }
            return false
        }.map { $0.processName }
    }
}

// MARK: - Touch Bar Errors

enum TouchBarError: LocalizedError {
    case noTouchBar
    case processNotFound
    case killFailed(String)
    case serviceRestartFailed
    case securityViolation(String)
    case adminRequired([String])  // List of processes that need admin
    case userCancelled           // User cancelled admin prompt
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
        case .adminRequired(let processes):
            return "Admin privileges required to restart: \(processes.joined(separator: ", "))"
        case .userCancelled:
            return "User cancelled the admin authorization"
        case .unknown(let message):
            return message
        }
    }
}
// MARK: - Touch Bar Manager

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
        // Quick initial detection based on model only (non-blocking)
        initialTouchBarDetection()
        // Force immediate update of published property
        objectWillChange.send()
    }

    // Fast, non-blocking initial detection based on model only
    private func initialTouchBarDetection() {
        let modelIdentifier = getModelIdentifier().trimmingCharacters(in: .whitespacesAndNewlines)
        let touchBarModels = [
            "MacBookPro13,2", "MacBookPro13,3", // 2016
            "MacBookPro14,2", "MacBookPro14,3", // 2017
            "MacBookPro15,1", "MacBookPro15,2", "MacBookPro15,3", "MacBookPro15,4", // 2018-2019
            "MacBookPro16,1", "MacBookPro16,2", "MacBookPro16,3", "MacBookPro16,4", // 2019-2020
            "MacBookPro17,1", // 2020 M1 13"
            "MacBookPro18,3", "MacBookPro18,4", // 2021 M1 Pro/Max
        ]

        hasTouchBar = touchBarModels.contains(modelIdentifier)

        print("Touch Bar Detection (Model Only):")
        print("   Model: \(modelIdentifier)")
        print("   Has Touch Bar: \(hasTouchBar)")
    }

    // Async method for full detection including process checking
    func performFullTouchBarDetection() async {
        await MainActor.run {
            checkTouchBarAvailability()
        }
    }

    // SECURITY: Validate and sanitize process names before use
    private func validateProcessName(_ processName: String) -> Bool {
        // Simply check if it's in our allowed list - that's the most important security check
        let isAllowed = allowedTouchBarProcesses.contains(processName)

        if !isAllowed {
            print("Process validation failed: '\(processName)' not in allowed list")
        }

        return isAllowed
    }

    // SECURITY: Sanitize process names to prevent injection
    private func sanitizeProcessName(_ processName: String) -> String {
        // Remove any non-alphanumeric characters except hyphens
        let sanitized = processName.components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted).joined()

        // SECURITY: Log sanitization for security monitoring
        if sanitized != processName {
            print("Process name sanitized: '\(processName)' -> '\(sanitized)'")
        }

        return sanitized
    }

    private func checkTouchBarAvailability() {
        // This is now called asynchronously after UI initialization
        // Check if this Mac model has a Touch Bar
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

        print("Full Touch Bar Detection:")
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
            print("Security: Invalid sysctl result or size: \(result), \(size)")
            return "Unknown"
        }

        var model = [CChar](repeating: 0, count: size)
        let readResult = sysctlbyname("hw.model", &model, &size, nil, 0)

        // SECURITY: Validate read result
        guard readResult == 0 else {
            print("Security: Failed to read sysctl: \(readResult)")
            return "Unknown"
        }

        return String(cString: model)
    }

    // MARK: - PID Helper

    /// Get the PID of a process by name
    /// - Parameter processName: The name of the process to find
    /// - Returns: The PID if the process is running, nil otherwise
    private func getProcessPID(_ processName: String) -> Int? {
        let task = Process()
        task.executableURL = URL(fileWithPath: "/usr/bin/pgrep")
        task.arguments = ["-x", processName]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let pid = Int(output.components(separatedBy: "\n").first ?? "") {
                    return pid
                }
            }
        } catch {}
        return nil
    }

    // MARK: - Main Restart Method

    func restartTouchBar() async -> Result<TouchBarRestartResult, TouchBarError> {
        // Re-check Touch Bar availability before restart
        checkTouchBarAvailability()

        print("Starting Touch Bar restart process...")
        print("   Device has Touch Bar: \(hasTouchBar)")
        print("   Model: \(getModelIdentifier())")

        // Enhanced logging for Console verification
        print("\n" + String(repeating: "=", count: 60))
        print("TOUCH BAR RESTART INITIATED")
        print("   Timestamp: \(Date())")
        print("   Device model: \(getModelIdentifier())")
        print("   Has Touch Bar: \(hasTouchBar)")
        print("   App: TouchBarFix 1.3.0")
        print(String(repeating: "=", count: 60))

        // Check if device has Touch Bar
        guard hasTouchBar else {
            print("No Touch Bar detected on this device")
            await MainActor.run {
                self.lastError = .noTouchBar
                self.isRestarting = false
            }
            return .failure(.noTouchBar)
        }

        // Check initial state of Touch Bar processes
        print("\nPRE-RESTART PROCESS STATUS:")
        for process in allowedTouchBarProcesses {
            let pid = getProcessPID(process)
            if let pid = pid {
                print("   - \(process): Running (PID: \(pid))")
            } else {
                print("   - \(process): Not Running")
            }
        }

        await MainActor.run {
            isRestarting = true
            lastError = nil
        }

        // SECURITY: Use validated, hardcoded process list instead of dynamic input
        let processes = Array(allowedTouchBarProcesses)
        var processResults: [ProcessRestartResult] = []
        var needsAdmin = false

        print("\nKILLING PROCESSES:")
        print("   Targets: \(processes.joined(separator: ", "))")

        for process in processes {
            let result = await secureKillProcess(process)
            processResults.append(result)

            if result.status == .permissionDenied {
                needsAdmin = true
                print("   - \(process): Permission denied (needs admin)")
            } else if case .failed(let msg) = result.status {
                print("   - \(process): Failed - \(msg)")
            } else if result.status == .notRunning {
                print("   - \(process): Was not running")
            } else {
                print("   - \(process): Killed successfully (was PID \(result.previousPID ?? 0))")
            }
        }

        print("\nWaiting 2 seconds for processes to restart...")
        // Wait for processes to restart
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Update results with new PIDs
        var updatedResults: [ProcessRestartResult] = []
        for result in processResults {
            let newPID = getProcessPID(result.processName)
            let updatedResult = ProcessRestartResult(
                processName: result.processName,
                status: result.status,
                previousPID: result.previousPID,
                newPID: newPID
            )
            updatedResults.append(updatedResult)
        }

        // Verify processes have restarted
        print("\nPOST-RESTART PROCESS STATUS:")
        for result in updatedResults {
            if let newPID = result.newPID {
                print("   - \(result.processName): Running (PID: \(newPID))")
            } else {
                print("   - \(result.processName): Not Running")
            }
        }

        // Calculate overall success
        // Success if all processes either succeeded, were not running, or we can handle via admin
        let hasHardFailures = updatedResults.contains {
            if case .failed = $0.status { return true }
            return false
        }

        let overallSuccess = !hasHardFailures && !needsAdmin

        let touchBarResult = TouchBarRestartResult(
            results: updatedResults,
            overallSuccess: overallSuccess,
            needsAdmin: needsAdmin
        )

        // Additional verification for critical processes
        print("\nVerifying critical Touch Bar processes:")
        let criticalProcesses = ["TouchBarServer", "ControlStrip"]
        var criticalRunning = true
        for process in criticalProcesses {
            let isRunning = checkIfProcessRunning(process)
            print("   - \(process): \(isRunning ? "VERIFIED RUNNING" : "NOT DETECTED")")
            if !isRunning && process == "TouchBarServer" {
                criticalRunning = false
            }
        }

        // Reset Touch Bar preferences if restart was successful and critical processes are running
        if overallSuccess && criticalRunning {
            print("Resetting Touch Bar preferences...")
            await resetTouchBarPreferences()

            await MainActor.run {
                self.lastRestartTime = Date()
                self.restartCount += 1
                self.saveData()
                self.isRestarting = false
            }

            print("\n" + String(repeating: "=", count: 60))
            print("TOUCH BAR RESTART COMPLETED SUCCESSFULLY!")
            print("   Restart Count: #\(restartCount)")
            print("   Timestamp: \(Date())")
            print("   Duration: ~2.5 seconds")
            print("   Final Status: \(getTouchBarStatus())")
            print(String(repeating: "=", count: 60) + "\n")
            return .success(touchBarResult)
        } else if needsAdmin {
            await MainActor.run {
                self.isRestarting = false
                self.lastError = .adminRequired(touchBarResult.processesNeedingAdmin)
            }

            print("\nTouch Bar restart requires admin privileges for:")
            for process in touchBarResult.processesNeedingAdmin {
                print("   - \(process)")
            }
            return .success(touchBarResult)  // Return success with needsAdmin flag
        } else {
            await MainActor.run {
                self.isRestarting = false
            }

            if hasHardFailures {
                print("Touch Bar restart failed - process termination issues")
                return .failure(lastError ?? .unknown("Failed to restart Touch Bar processes"))
            } else {
                print("Touch Bar restart completed but critical processes not detected")
                print("   This may indicate a deeper system issue")
                return .failure(.serviceRestartFailed)
            }
        }
    }

    // MARK: - Admin Escalation Method

    /// Restart Touch Bar processes with administrator privileges using AppleScript
    /// This will prompt the user for their password
    func restartTouchBarWithAdmin() async -> Result<Void, TouchBarError> {
        print("\n" + String(repeating: "=", count: 60))
        print("ADMIN RESTART INITIATED")
        print("   Timestamp: \(Date())")
        print("   Requesting administrator privileges...")
        print(String(repeating: "=", count: 60))

        // AppleScript to kill TouchBarServer with admin privileges
        // We focus on TouchBarServer since it's the root process that needs admin
        let script = """
        do shell script "pkill -9 TouchBarServer" with administrator privileges
        """

        let task = Process()
        task.executableURL = URL(fileWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]

        let errorPipe = Pipe()
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()

            let terminationStatus = task.terminationStatus
            print("   osascript returned: \(terminationStatus)")

            if terminationStatus == 0 {
                print("   Admin kill successful, waiting for process to restart...")

                // Wait for process to restart
                try? await Task.sleep(nanoseconds: 2_000_000_000)

                // Verify TouchBarServer restarted
                if let newPID = getProcessPID("TouchBarServer") {
                    print("   TouchBarServer restarted with PID: \(newPID)")

                    await MainActor.run {
                        self.lastRestartTime = Date()
                        self.restartCount += 1
                        self.saveData()
                    }

                    print("\n" + String(repeating: "=", count: 60))
                    print("ADMIN RESTART COMPLETED SUCCESSFULLY!")
                    print(String(repeating: "=", count: 60) + "\n")

                    return .success(())
                } else {
                    print("   Warning: TouchBarServer did not restart")
                    return .failure(.serviceRestartFailed)
                }
            } else if terminationStatus == 1 {
                // User cancelled the admin prompt
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? ""

                if errorString.contains("User canceled") || errorString.contains("canceled") {
                    print("   User cancelled admin authorization")
                    return .failure(.userCancelled)
                } else {
                    print("   Admin restart failed: \(errorString)")
                    return .failure(.killFailed("Admin restart failed: \(errorString)"))
                }
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("   Admin restart failed with status \(terminationStatus): \(errorString)")
                return .failure(.killFailed("Admin restart failed: \(errorString)"))
            }
        } catch {
            print("   Exception during admin restart: \(error.localizedDescription)")
            return .failure(.unknown(error.localizedDescription))
        }
    }

    // MARK: - Secure Process Termination

    /// Securely kill a process with proper validation and permission detection
    /// - Parameter processName: The name of the process to kill
    /// - Returns: ProcessRestartResult with status including permission denied detection
    private func secureKillProcess(_ processName: String) async -> ProcessRestartResult {
        // SECURITY: Validate process name before any operations
        guard validateProcessName(processName) else {
            print("Security violation: Invalid process name: '\(processName)'")
            return ProcessRestartResult(
                processName: processName,
                status: .failed("Security violation: Invalid process name"),
                previousPID: nil,
                newPID: nil
            )
        }

        // SECURITY: Double-check against allowed list
        guard allowedTouchBarProcesses.contains(processName) else {
            print("Security violation: Unauthorized process: '\(processName)'")
            return ProcessRestartResult(
                processName: processName,
                status: .failed("Security violation: Unauthorized process"),
                previousPID: nil,
                newPID: nil
            )
        }

        // Get the PID before attempting to kill
        let previousPID = getProcessPID(processName)
        let wasRunning = previousPID != nil

        print("   Attempting to kill process: \(processName) (PID: \(previousPID.map { String($0) } ?? "not running"))")

        let task = Process()
        task.executableURL = URL(fileWithPath: "/usr/bin/pkill")
        task.arguments = ["-9", processName]  // Use -9 for SIGKILL

        let errorPipe = Pipe()
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()

            let terminationStatus = task.terminationStatus

            // Interpret exit codes with context of whether process was running
            // Exit code 0: Successfully killed
            // Exit code 1: No process matched OR permission denied
            // We distinguish by checking if process was running before

            if terminationStatus == 0 {
                // Successfully killed
                return ProcessRestartResult(
                    processName: processName,
                    status: .success,
                    previousPID: previousPID,
                    newPID: nil
                )
            } else if terminationStatus == 1 {
                if wasRunning {
                    // Process was running but pkill returned 1 = permission denied
                    print("   pkill returned 1 but process was running - permission denied")
                    return ProcessRestartResult(
                        processName: processName,
                        status: .permissionDenied,
                        previousPID: previousPID,
                        newPID: nil
                    )
                } else {
                    // Process was not running - that's OK
                    return ProcessRestartResult(
                        processName: processName,
                        status: .notRunning,
                        previousPID: nil,
                        newPID: nil
                    )
                }
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                return ProcessRestartResult(
                    processName: processName,
                    status: .failed(errorString),
                    previousPID: previousPID,
                    newPID: nil
                )
            }
        } catch {
            return ProcessRestartResult(
                processName: processName,
                status: .failed(error.localizedDescription),
                previousPID: previousPID,
                newPID: nil
            )
        }
    }

    // MARK: - Preferences Reset

    private func resetTouchBarPreferences() async {
        print("Resetting Touch Bar preferences and cache...")

        // SECURITY: Hardcoded, validated preference domains
        let preferenceDomains = [
            "com.apple.touchbar.agent",
            "com.apple.controlstrip",
            "com.apple.TouchBarAgent"
        ]

        for domain in preferenceDomains {
            let task = Process()
            task.executableURL = URL(fileWithPath: "/usr/bin/defaults")
            task.arguments = ["delete", domain]

            do {
                try task.run()
                task.waitUntilExit()
                if task.terminationStatus == 0 {
                    print("   Cleared \(domain)")
                }
            } catch {
                // Ignore errors - domain might not exist
            }
        }

        // Also restart the Dock to refresh Touch Bar state
        let dockTask = Process()
        dockTask.executableURL = URL(fileWithPath: "/usr/bin/killall")
        dockTask.arguments = ["Dock"]

        do {
            try dockTask.run()
            dockTask.waitUntilExit()
            print("   Restarted Dock to refresh Touch Bar")
        } catch {
            print("   Could not restart Dock: \(error)")
        }
    }

    // MARK: - Data Persistence

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

    // MARK: - Status Methods

    func getTouchBarStatus() -> String {
        guard hasTouchBar else {
            return "No Touch Bar"
        }

        let task = Process()
        task.executableURL = URL(fileWithPath: "/usr/bin/pgrep")
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
            print("Security: Attempted to check invalid process: '\(processName)'")
            return false
        }

        let task = Process()
        task.executableURL = URL(fileWithPath: "/usr/bin/pgrep")
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
