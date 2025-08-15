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
    var popover: NSPopover?
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
            button.action = #selector(handleClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            // Make the icon template so it adapts to dark/light mode
            button.image?.isTemplate = true
        }
        
        // Create menu for right-click
        setupMenu()
        
        // Create popover with QuickActionView
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 250, height: 180)
        popover?.behavior = .transient
        
        let quickActionView = QuickActionView()
            .environment(\.dismissWindow) { [weak self] in
                self?.popover?.performClose(nil)
            }
        
        popover?.contentViewController = NSHostingController(rootView: quickActionView)
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
        
        menu?.addItem(NSMenuItem.separator())
        
        // Settings item
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu?.addItem(settingsItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit Touch Bar Restarter", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu?.addItem(quitItem)
    }
    
    @objc func handleClick() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Show menu on right-click
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil
        } else {
            // Show popover on left-click
            togglePopover()
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
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
    
    @objc func showSettings() {
        // For now, just show the popover
        togglePopover()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func showWelcomeNotification() {
        let alert = NSAlert()
        alert.messageText = "Touch Bar Restarter is Ready!"
        alert.informativeText = "🔄 Left-click the ↻ icon: Quick restart\n🖱️ Right-click the ↻ icon: Full menu\n⌨️ Keyboard shortcuts: ⌘R (restart), ⌘Q (quit)\n\nThe app will stay running in your menu bar until you quit it."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Start Using")
        alert.addButton(withTitle: "Show Settings")
        
        // Add icon to the alert
        alert.icon = NSImage(systemSymbolName: "arrow.clockwise.circle.fill", accessibilityDescription: "Touch Bar Restarter")
        
        let response = alert.runModal()
        
        // If user clicked "Show Settings", open the popover
        if response == .alertSecondButtonReturn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.togglePopover()
            }
        }
    }
}
