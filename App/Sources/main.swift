import SwiftUI
import AppKit
import Foundation

// AppDelegate for window-based app
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as regular app (shows in Dock and App Switcher)
        NSApp.setActivationPolicy(.regular)
        
        // Create and configure window
        // Start at idle size, will resize for dashboard when needed
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 360),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        // Allow window to resize based on content
        window.contentMinSize = NSSize(width: 420, height: 360)
        window.contentMaxSize = NSSize(width: 800, height: 600)
        
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