import Foundation
import AppKit

class TouchBarManager: ObservableObject {
    @Published var isRestarting = false
    @Published var lastRestartTime: Date?
    @Published var restartCount = 0
    
    private let userDefaults = UserDefaults.standard
    private let restartCountKey = "TouchBarRestartCount"
    private let lastRestartKey = "LastTouchBarRestart"
    
    init() {
        loadData()
    }
    
    func restartTouchBar() async -> Bool {
        await MainActor.run {
            isRestarting = true
        }
        
        // Method 1: Kill Touch Bar process
        let success = await killTouchBarProcess()
        
        if success {
            // Method 2: Reset Touch Bar preferences
            await resetTouchBarPreferences()
            
            // Method 3: Restart Touch Bar service
            await restartTouchBarService()
            
            await MainActor.run {
                self.lastRestartTime = Date()
                self.restartCount += 1
                self.saveData()
            }
            
            await MainActor.run {
                self.isRestarting = false
            }
            
            return true
        }
        
        await MainActor.run {
            self.isRestarting = false
        }
        
        return false
    }
    
    private func killTouchBarProcess() async -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pkill"
        task.arguments = ["-f", "TouchBarServer"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Wait a bit for the process to fully terminate
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            return task.terminationStatus == 0
        } catch {
            print("Failed to kill Touch Bar process: \(error)")
            return false
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
    
    private func restartTouchBarService() async {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["ControlCenter"]
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("Failed to restart Touch Bar service: \(error)")
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
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-f", "TouchBarServer"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0 ? "Running" : "Not Running"
        } catch {
            return "Unknown"
        }
    }
}
