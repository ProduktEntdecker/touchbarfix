import SwiftUI

struct ContentView: View {
    @StateObject private var touchBarManager = TouchBarManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Touch Bar Restart"
    @State private var showingSuccess = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Header with Touch Bar Logo
            VStack(spacing: 20) {
                // TouchBarFix Logo - Create Touch Bar representation with colored rectangles
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 24, height: 18)
                        .cornerRadius(3)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 24, height: 18)
                        .cornerRadius(3)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 24, height: 18)
                        .cornerRadius(3)
                    Rectangle()
                        .fill(Color.mint)
                        .frame(width: 24, height: 18)
                        .cornerRadius(3)
                }
                .padding(8)
                .background(Color.black)
                .cornerRadius(12)
                
                Text("TouchBarFix")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(touchBarManager.hasTouchBar ? 
                     "Fix your unresponsive Touch Bar with one click" : 
                     "No Touch Bar detected on this device")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Main Action Button - Properly sized and positioned
            Button(action: restartTouchBar) {
                HStack(spacing: 12) {
                    if touchBarManager.isRestarting {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(.white)
                    } else {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.title2)
                    }
                    Text(touchBarManager.isRestarting ? "Fixing Touch Bar..." : "Fix Touch Bar")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if touchBarManager.isRestarting {
                            Color.orange
                        } else if !touchBarManager.hasTouchBar {
                            Color.gray
                        } else {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .disabled(touchBarManager.isRestarting || !touchBarManager.hasTouchBar)
            .scaleEffect(touchBarManager.isRestarting ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: touchBarManager.isRestarting)
            .padding(.horizontal, 24) // Better button positioning
            
            // Secondary Actions - Minimal
            HStack(spacing: 24) {
                Button(action: showHelp) {
                    VStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                        Text("Help")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: quitApp) {
                    VStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                        Text("Quit")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 60)
            
            Spacer()
        }
        .padding(32)
        .frame(width: 420, height: 360)
        .background(Color.white)
        .alert(alertTitle, isPresented: $showingAlert) {
            if showingSuccess {
                Button("Done") {
                    quitApp()
                }
                Button("Fix Again") { 
                    showingSuccess = false
                    restartTouchBar()
                }
                // Subtle sharing option - not pushy
                Button("Tell a Friend") {
                    shareSuccess()
                }
            } else {
                Button("OK") { }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkForErrors()
        }
        .task {
            // Perform full Touch Bar detection after UI is initialized
            await touchBarManager.performFullTouchBarDetection()
        }
    }
    
    private func restartTouchBar() {
        Task {
            let result = await touchBarManager.restartTouchBar()
            
            await MainActor.run {
                switch result {
                case .success:
                    alertTitle = "Success! ✅"
                    // Priority 1: Celebrate success
                    // Priority 2: Subtle sharing suggestion
                    alertMessage = "Touch Bar has been successfully restarted!\n\nYour Touch Bar should now be responsive."
                    showingSuccess = true
                case .failure(let error):
                    alertTitle = "Error ❌"
                    alertMessage = error.localizedDescription
                    showingSuccess = false
                }
                showingAlert = true
            }
        }
    }
    
    private func shareSuccess() {
        let text = "PSA: TouchBarFix just instantly solved my frozen Touch Bar issue. Bookmarking this for the next time someone complains about unresponsive Touch Bar controls 🙌"
        let url = URL(string: "https://touchbarfix.com?utm_source=app&utm_medium=share")!
        
        let items: [Any] = [text, url]
        
        // Priority order: Slack > Email > Messages > Generic
        let preferredServices: [NSSharingService.Name] = [
            .init("com.tinyspeck.slackmacgap"), // Slack
            .composeEmail,
            .composeMessage
        ]
        
        // Try to find preferred service first
        if let preferredService = preferredServices.compactMap({ NSSharingService(named: $0) }).first {
            if preferredService.canPerform(withItems: items) {
                preferredService.perform(withItems: items)
                return
            }
        }
        
        // Fallback to picker
        let activityVC = NSSharingServicePicker(items: items)
        if let window = NSApp.windows.first {
            activityVC.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
        }
    }
    
    private func checkForErrors() {
        if let error = touchBarManager.lastError {
            alertTitle = "Warning ⚠️"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func showHelp() {
        if let url = URL(string: "https://touchbarfix.com/support.html") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

#Preview {
    ContentView()
}