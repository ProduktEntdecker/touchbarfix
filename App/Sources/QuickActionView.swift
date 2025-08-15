import SwiftUI

struct QuickActionView: View {
    @StateObject private var touchBarManager = TouchBarManager()
    @State private var isRestarting = false
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with icon and title
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Touch Bar Restarter")
                        .font(.headline)
                    Text("Status: \(touchBarManager.getTouchBarStatus())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Quick restart button
            Button(action: {
                restartTouchBar()
            }) {
                HStack {
                    if isRestarting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text(isRestarting ? "Restarting..." : "Restart Now")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRestarting || !touchBarManager.hasTouchBar)
            
            // Quick stats
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Restarts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(touchBarManager.restartCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if let lastRestart = touchBarManager.lastRestartTime {
                    VStack(alignment: .trailing) {
                        Text("Last Restart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastRestart, style: .relative)
                            .font(.caption)
                    }
                }
            }
            
            Divider()
            
            // Action buttons
            HStack {
                Button("Settings") {
                    // This will be handled by the main app delegate
                    dismissWindow?()
                }
                .buttonStyle(.plain)
                .font(.caption)
                
                Spacer()
                
                Button("Quit") {
                    dismissWindow?()
                    DispatchQueue.main.async {
                        NSApplication.shared.terminate(nil)
                    }
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 250)
        .onAppear {
            touchBarManager.objectWillChange.send()
        }
    }
    
    private func restartTouchBar() {
        isRestarting = true
        
        Task {
            let result = await touchBarManager.restartTouchBar()
            
            await MainActor.run {
                isRestarting = false
                
                // Show brief feedback
                let alert = NSAlert()
                switch result {
                case .success:
                    alert.messageText = "✅ Success!"
                    alert.informativeText = "Touch Bar restarted successfully."
                    alert.alertStyle = .informational
                case .failure(let error):
                    alert.messageText = "❌ Error"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                }
                
                // Auto-close after short delay for success
                if case .success = result {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Close popover after success
                        dismissWindow?()
                    }
                }
                
                alert.runModal()
            }
        }
    }
}

// Add environment key for dismiss
struct DismissWindowKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var dismissWindow: (() -> Void)? {
        get { self[DismissWindowKey.self] }
        set { self[DismissWindowKey.self] = newValue }
    }
}