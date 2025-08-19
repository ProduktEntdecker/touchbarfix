import SwiftUI
import AppKit
import Foundation

// Check for existing instance
func checkSingleInstance() -> Bool {
    let bundleIdentifier = "com.produktentdecker.touchbarfix"
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
    
    if !existingInstances.isEmpty {
        // Show duplicate instance alert
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        let alert = NSAlert()
        alert.messageText = "TouchBarFix is Already Running"
        alert.informativeText = "Another instance of TouchBarFix is already running. Please quit the existing instance before starting a new one."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Warning")
        
        alert.runModal()
        return false
    }
    
    return true
}

// AppDelegate for window-based app
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check for duplicate instance
        if !checkSingleInstance() {
            NSApplication.shared.terminate(nil)
            return
        }
        
        // Set as regular app (shows in Dock and App Switcher)
        NSApp.setActivationPolicy(.regular)
        
        // Create and configure window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 320),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "TouchBarFix"
        window.isReleasedWhenClosed = false
        
        // Create SwiftUI view and set as window content
        let contentView = ContentView()
        window.contentView = NSHostingView(rootView: contentView)
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        
        // Activate app
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
