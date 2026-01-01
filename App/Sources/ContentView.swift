import SwiftUI

// MARK: - Flow State Enum

/// Represents the current UI flow state for the Touch Bar restart process
enum ContentViewFlowState: Equatable {
    case idle
    case restarting
    case success(usedAdmin: Bool)
    case partialFailure(needsAdmin: Bool)
    case failure(String)
}

struct ContentView: View {
    @StateObject private var touchBarManager = TouchBarManager()
    @StateObject private var restartProgress = RestartProgress()
    @State private var flowState: ContentViewFlowState = .idle
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Touch Bar Restart"
    @State private var showingSuccess = false
    @Environment(\.dismiss) private var dismiss

    /// Computed property to check if restart is in progress
    private var isRestarting: Bool {
        if case .restarting = flowState { return true }
        return false
    }

    var body: some View {
        Group {
            if flowState == .idle {
                mainContentView
            } else {
                // Dashboard view for all non-idle states
                TouchBarDashboardView(
                    progress: restartProgress,
                    flowState: flowState,
                    onGrantAdmin: handleGrantAdmin,
                    onRestartComputer: handleRestartComputer,
                    onCancel: { resetToIdle() },
                    onDone: { quitApp() },
                    onTryAgain: { restartTouchBar() },
                    onShare: { shareSuccess() }
                )
            }
        }
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

    // MARK: - Main Content View

    private var mainContentView: some View {
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

                Text(subtitleText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Main Action Button - Properly sized and positioned
            Button(action: restartTouchBar) {
                HStack(spacing: 12) {
                    if isRestarting {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(.white)
                    } else {
                        Image(systemName: buttonIcon)
                            .font(.title2)
                    }
                    Text(buttonText)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(buttonBackground)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .disabled(isRestarting || !touchBarManager.hasTouchBar)
            .scaleEffect(isRestarting ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isRestarting)
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
    }

    // MARK: - Computed Properties for UI State

    private var subtitleText: String {
        switch flowState {
        case .idle:
            return touchBarManager.hasTouchBar ?
                "Fix your unresponsive Touch Bar with one click" :
                "No Touch Bar detected on this device"
        case .restarting:
            return "Restarting Touch Bar processes..."
        case .success(let usedAdmin):
            return usedAdmin ?
                "Touch Bar restarted successfully (Admin)" :
                "Touch Bar restarted successfully!"
        case .partialFailure:
            return "Some processes need elevated privileges"
        case .failure(let message):
            return message
        }
    }

    private var buttonIcon: String {
        switch flowState {
        case .success:
            return "checkmark.circle.fill"
        case .failure, .partialFailure:
            return "arrow.clockwise"
        default:
            return "wrench.and.screwdriver.fill"
        }
    }

    private var buttonText: String {
        switch flowState {
        case .idle:
            return "Fix Touch Bar"
        case .restarting:
            return "Fixing Touch Bar..."
        case .success:
            return "Fixed!"
        case .partialFailure, .failure:
            return "Try Again"
        }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch flowState {
        case .restarting:
            Color.orange
        case .success:
            Color.green
        case .failure, .partialFailure:
            Color.orange
        case .idle:
            if !touchBarManager.hasTouchBar {
                Color.gray
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    
    // MARK: - Actions

    private func restartTouchBar() {
        // Reset progress and set state to restarting
        restartProgress.reset()
        flowState = .restarting

        Task {
            // Show "in progress" for all processes while restart runs
            await MainActor.run {
                restartProgress.updateStatus(for: "controlStrip", status: .inProgress)
                restartProgress.updateStatus(for: "touchBarServer", status: .inProgress)
                restartProgress.updateStatus(for: "displayRefresh", status: .inProgress)
            }

            // Perform actual restart
            let result = await touchBarManager.restartTouchBar()

            await MainActor.run {
                switch result {
                case .success(let touchBarResult):
                    // Update progress with REAL results from each process
                    updateProgressFromResults(touchBarResult)

                case .failure(let error):
                    restartProgress.controlStrip = .failed(reason: .unknown(error.localizedDescription))
                    restartProgress.touchBarServer = .failed(reason: .unknown(error.localizedDescription))
                    restartProgress.displayRefresh = .failed(reason: .unknown(error.localizedDescription))
                    restartProgress.overallState = .failure(error.localizedDescription)
                }
            }

            // Wait so user can see the actual status before transitioning
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s

            await MainActor.run {
                switch result {
                case .success(let touchBarResult):
                    if touchBarResult.needsAdmin {
                        // Partial failure - dashboard will show admin options
                        flowState = .partialFailure(needsAdmin: true)
                    } else if touchBarResult.overallSuccess {
                        // Full success
                        flowState = .success(usedAdmin: false)
                        showSuccessAlert(usedAdmin: false)
                    } else {
                        // Failure
                        let failedProcesses = touchBarResult.failedProcesses.joined(separator: ", ")
                        flowState = .failure("Failed to restart: \(failedProcesses)")
                    }
                case .failure(let error):
                    flowState = .failure(error.localizedDescription)
                }
            }
        }
    }

    /// Update progress view with real results from TouchBarManager
    private func updateProgressFromResults(_ result: TouchBarRestartResult) {
        for processResult in result.results {
            let status: UIProcessStatus
            switch processResult.status {
            case .success:
                status = .success
            case .notRunning:
                status = .success // Not running is OK - process wasn't needed
            case .permissionDenied:
                status = .failed(reason: .needsAdmin)
            case .failed(let message):
                status = .failed(reason: .unknown(message))
                print("Process \(processResult.processName) failed: \(message)")
            }

            // Map process names to our UI identifiers
            switch processResult.processName {
            case "ControlStrip":
                restartProgress.controlStrip = status
            case "TouchBarServer":
                restartProgress.touchBarServer = status
            default:
                // Other processes go to displayRefresh
                restartProgress.displayRefresh = status
            }
        }

        // Update overall state
        if result.needsAdmin {
            restartProgress.overallState = .partialFailure(needsAdmin: true)
        } else if result.overallSuccess {
            restartProgress.overallState = .success
        } else {
            restartProgress.overallState = .failure("Some processes failed to restart")
        }
    }

    private func handleProgressComplete(_ state: OverallRestartState) {
        switch state {
        case .success:
            flowState = .success(usedAdmin: false)
        case .partialFailure(let needsAdmin):
            flowState = .partialFailure(needsAdmin: needsAdmin)
        case .failure(let message):
            flowState = .failure(message)
        default:
            break
        }
    }

    private func handleGrantAdmin() {
        flowState = .restarting

        // Reset progress for admin restart
        restartProgress.reset()
        restartProgress.updateStatus(for: "touchBarServer", status: .inProgress)

        Task {
            let result = await touchBarManager.restartTouchBarWithAdmin()

            await MainActor.run {
                switch result {
                case .success:
                    restartProgress.updateStatus(for: "touchBarServer", status: .success)
                    restartProgress.updateStatus(for: "controlStrip", status: .success)
                    restartProgress.updateStatus(for: "displayRefresh", status: .success)
                    flowState = .success(usedAdmin: true)
                    showSuccessAlert(usedAdmin: true)
                case .failure(let error):
                    if case .userCancelled = error {
                        // User cancelled - go back to partial failure state
                        flowState = .partialFailure(needsAdmin: true)
                    } else {
                        flowState = .failure(error.localizedDescription)
                        restartProgress.overallState = .failure(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func handleRestartComputer() {
        // Use AppleScript to trigger system restart
        let script = """
        tell application "System Events"
            restart
        end tell
        """

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", script]

        do {
            try task.run()
        } catch {
            // If restart fails, show error
            flowState = .failure("Could not initiate system restart: \(error.localizedDescription)")
        }
    }

    private func resetToIdle() {
        flowState = .idle
        restartProgress.reset()
    }

    private func showSuccessAlert(usedAdmin: Bool) {
        alertTitle = usedAdmin ? "Success! (Admin)" : "Success!"
        alertMessage = "Touch Bar has been successfully restarted!\n\nYour Touch Bar should now be responsive."
        showingSuccess = true
        showingAlert = true
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
        if let window = NSApp.windows.first, let contentView = window.contentView {
            activityVC.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
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