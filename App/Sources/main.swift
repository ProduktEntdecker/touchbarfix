import SwiftUI
import AppKit
import Foundation

// AppDelegate for window-based app
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set as regular app (shows in Dock and App Switcher)
        NSApp.setActivationPolicy(.regular)

        // Install the standard macOS main menu (App / Edit / Window / Help).
        // Without this there is no "About TouchBarFix", no ⌘Q, and no copy/paste.
        NSApp.mainMenu = buildMainMenu()

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

    // MARK: - Standard About panel

    @objc func showAboutPanel(_ sender: Any?) {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        let copyright = info?["NSHumanReadableCopyright"] as? String
            ?? "Copyright © ProduktEntdecker"

        var options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationVersion: version,
            .version: build
        ]
        options[.credits] = NSAttributedString(
            string: "Fixes a frozen Touch Bar on MacBook Pro (2016–2022).\nhttps://touchbarfix.com",
            attributes: [.font: NSFont.systemFont(ofSize: 11)]
        )
        options[NSApplication.AboutPanelOptionKey(rawValue: "Copyright")] = copyright

        NSApp.orderFrontStandardAboutPanel(options: options)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func openSupport(_ sender: Any?) {
        if let url = URL(string: "https://touchbarfix.com/support.html") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Main menu construction

    private func buildMainMenu() -> NSMenu {
        let appName = (Bundle.main.infoDictionary?["CFBundleName"] as? String)
            ?? ProcessInfo.processInfo.processName
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(withTitle: "About \(appName)",
                        action: #selector(showAboutPanel(_:)),
                        keyEquivalent: "").target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide \(appName)",
                        action: #selector(NSApplication.hide(_:)),
                        keyEquivalent: "h")
        let hideOthers = appMenu.addItem(withTitle: "Hide Others",
                                         action: #selector(NSApplication.hideOtherApplications(_:)),
                                         keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: "Show All",
                        action: #selector(NSApplication.unhideAllApplications(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit \(appName)",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        // Edit menu (enables copy/paste, e.g. on the share screen)
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Minimize",
                           action: #selector(NSWindow.performMiniaturize(_:)),
                           keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom",
                           action: #selector(NSWindow.performZoom(_:)),
                           keyEquivalent: "")
        NSApp.windowsMenu = windowMenu

        // Help menu
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        helpMenu.addItem(withTitle: "TouchBarFix Support",
                         action: #selector(openSupport(_:)),
                         keyEquivalent: "?").target = self
        NSApp.helpMenu = helpMenu

        return mainMenu
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()