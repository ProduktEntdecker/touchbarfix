import SwiftUI
import AppKit
import Foundation

// Check for existing instance
func checkSingleInstance() -> Bool {
    let bundleIdentifier = "com.produktentdecker.touchbarrestarter"
    let runningApps = NSWorkspace.shared.runningApplications
    
    // Count apps with our bundle identifier that are already running
    let existingInstances = runningApps.filter { app in
        app.bundleIdentifier == bundleIdentifier && 
        app.processIdentifier != ProcessInfo.processInfo.processIdentifier
    }
    
    print("🔍 Single instance check:")
    print("   Current PID: \(ProcessInfo.processInfo.processIdentifier)")
    print("   Bundle ID: \(bundleIdentifier)")
    print("   Existing instances: \(existingInstances.count)")
    
    for instance in existingInstances {
        print("   Found existing: PID \(instance.processIdentifier)")
    }
    
    return existingInstances.isEmpty
}

// Main entry point for the app
if !checkSingleInstance() {
    print("❌ Another instance is already running - showing error dialog")
    
    // Ensure we can show UI
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate(ignoringOtherApps: true)
    
    let alert = NSAlert()
    alert.messageText = "Touch Bar Restarter is Already Running"
    alert.informativeText = "Another instance of Touch Bar Restarter is already running in your menu bar. Please quit the existing instance before starting a new one."
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Warning")
    
    // Make sure the alert appears on top
    DispatchQueue.main.async {
        alert.runModal()
        print("✅ Error dialog dismissed - exiting")
        exit(0)
    }
    
    // Keep app alive long enough to show dialog
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    var touchBarManager = TouchBarManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Development mode: show in dock and app switcher for easier access
        #if DEBUG
        NSApp.setActivationPolicy(.regular)
        #else
        NSApp.setActivationPolicy(.accessory)
        #endif
        
        // Show welcome notification on every launch for better UX
        showWelcomeNotification()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Use a more visible icon - restart symbol
            button.image = NSImage(systemSymbolName: "arrow.clockwise.circle.fill", accessibilityDescription: "Touch Bar Restarter")
            button.action = #selector(showMenu)
            button.target = self
            
            // Make the icon template so it adapts to dark/light mode
            button.image?.isTemplate = true
        }
        
        // Create menu for both left and right clicks
        setupMenu()
    }
    
    func setupMenu() {
        menu = NSMenu()
        
        // Quick restart item (main action)
        let restartItem = NSMenuItem(title: "🔄 Restart Touch Bar Now", action: #selector(quickRestart), keyEquivalent: "r")
        restartItem.target = self
        menu?.addItem(restartItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Status item
        let statusItem = NSMenuItem(title: "Status: \(touchBarManager.getTouchBarStatus())", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu?.addItem(statusItem)
        
        // Restart count
        let countItem = NSMenuItem(title: "Restarts: \(touchBarManager.restartCount)", action: nil, keyEquivalent: "")
        countItem.isEnabled = false
        menu?.addItem(countItem)
        
        // Version info
        let versionItem = NSMenuItem(title: "Version: 1.2.0", action: nil, keyEquivalent: "")
        versionItem.isEnabled = false
        menu?.addItem(versionItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Report Issue item
        let reportItem = NSMenuItem(title: "🐛 Report Issue...", action: #selector(reportIssue), keyEquivalent: "i")
        reportItem.target = self
        menu?.addItem(reportItem)
        
        // About item
        let aboutItem = NSMenuItem(title: "ℹ️ About Touch Bar Restarter...", action: #selector(showAbout), keyEquivalent: "a")
        aboutItem.target = self
        menu?.addItem(aboutItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit Touch Bar Restarter", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu?.addItem(quitItem)
    }
    
    @objc func showMenu() {
        // Show menu for both left and right clicks
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc func quickRestart() {
        Task {
            let result = await touchBarManager.restartTouchBar()
            
            await MainActor.run {
                let alert = NSAlert()
                switch result {
                case .success:
                    alert.messageText = "Success!"
                    alert.informativeText = "Touch Bar has been restarted."
                    alert.alertStyle = .informational
                case .failure(let error):
                    alert.messageText = "Error"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                }
                alert.runModal()
                
                // Update menu with new status
                setupMenu()
            }
        }
    }
    
    @objc func reportIssue() {
        // Open GitHub Issues page
        if let url = URL(string: "https://github.com/ProduktEntdecker/touchbar-restarter/issues") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func showAbout() {
        // Open about/landing page - TODO: Update to produktentdecker.com when ready
        if let url = URL(string: "https://github.com/ProduktEntdecker/touchbar-restarter") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func showWelcomeNotification() {
        let alert = NSAlert()
        alert.messageText = "Touch Bar Restarter is Ready!"
        alert.informativeText = "🔄 Click the ↻ icon to restart your Touch Bar\n⌨️ Keyboard shortcuts: ⌘R (restart), ⌘I (report issue), ⌘Q (quit)\n🐛 Having issues? Use ⌘I to report them\n\nThe app will stay running in your menu bar until you quit it."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Start Using")
        alert.addButton(withTitle: "Show Menu")
        
        // Add icon to the alert
        alert.icon = NSImage(systemSymbolName: "arrow.clockwise.circle.fill", accessibilityDescription: "Touch Bar Restarter")
        
        let response = alert.runModal()
        
        // If user clicked "Show Menu", show the menu
        if response == .alertSecondButtonReturn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showMenu()
            }
        }
    }
}
