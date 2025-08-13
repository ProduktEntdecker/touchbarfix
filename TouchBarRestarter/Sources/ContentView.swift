import SwiftUI

struct ContentView: View {
    @StateObject private var touchBarManager = TouchBarManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "touchid")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Touch Bar Restarter")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Restart your Touch Bar when it's unresponsive")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            // Touch Bar Status
            HStack {
                Text("Status:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(touchBarManager.getTouchBarStatus())
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Main Action Button
            Button(action: restartTouchBar) {
                HStack {
                    if touchBarManager.isRestarting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text(touchBarManager.isRestarting ? "Restarting..." : "Restart Touch Bar")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(touchBarManager.isRestarting ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(touchBarManager.isRestarting)
            
            // Stats
            VStack(spacing: 8) {
                if let lastRestart = touchBarManager.lastRestartTime {
                    HStack {
                        Text("Last Restart:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastRestart, style: .relative)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                HStack {
                    Text("Total Restarts:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(touchBarManager.restartCount)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 250)
        .alert("Touch Bar Restart", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func restartTouchBar() {
        Task {
            let success = await touchBarManager.restartTouchBar()
            
            await MainActor.run {
                if success {
                    alertMessage = "Touch Bar has been successfully restarted!"
                } else {
                    alertMessage = "Failed to restart Touch Bar. Please try again."
                }
                showingAlert = true
            }
        }
    }
}

// Preview removed for compatibility
