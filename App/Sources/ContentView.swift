import SwiftUI

struct ContentView: View {
    @StateObject private var touchBarManager = TouchBarManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Touch Bar Restart"
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: touchBarManager.hasTouchBar ? "touchid" : "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(touchBarManager.hasTouchBar ? .blue : .orange)
                
                Text("Touch Bar Restarter")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(touchBarManager.hasTouchBar ? 
                     "Restart your Touch Bar when it's unresponsive" : 
                     "No Touch Bar detected on this device")
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
                .background(touchBarManager.isRestarting || !touchBarManager.hasTouchBar ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(touchBarManager.isRestarting || !touchBarManager.hasTouchBar)
            
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
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkForErrors()
        }
    }
    
    private func restartTouchBar() {
        Task {
            let result = await touchBarManager.restartTouchBar()
            
            await MainActor.run {
                switch result {
                case .success:
                    alertTitle = "Success"
                    alertMessage = "Touch Bar has been successfully restarted!"
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                }
                showingAlert = true
            }
        }
    }
    
    private func checkForErrors() {
        if let error = touchBarManager.lastError {
            alertTitle = "Warning"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

// Preview removed for compatibility
