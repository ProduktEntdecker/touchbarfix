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
    @State private var showingRestartOptions = false
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
        ZStack {
            mainContentView

            // Overlay for progress view during restart
            if case .restarting = flowState {
                progressOverlay
            }

            // Overlay for restart options on partial failure
            if showingRestartOptions {
                optionsOverlay
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

    // MARK: - Overlay Views

    private var progressOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            RestartProgressView(
                progress: restartProgress,
                onComplete: { state in
                    handleProgressComplete(state)
                },
                onDismiss: {
                    resetToIdle()
                }
            )
        }
        .transition(.opacity)
    }

    private var optionsOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            RestartOptionsView(
                onGrantAdmin: {
                    handleGrantAdmin()
                },
                onRestartComputer: {
                    handleRestartComputer()
                },
                onCancel: {
                    showingRestartOptions = false
                    resetToIdle()
                }
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .transition(.opacity)
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
            // Simulate progress updates for each process
            await simulateProgressUpdates()

            let result = await touchBarManager.restartTouchBar()

            await MainActor.run {
                switch result {
                case .success(let touchBarResult):
                    if touchBarResult.needsAdmin {
                        // Partial failure - show options dialog
                        flowState = .partialFailure(needsAdmin: true)
                        restartProgress.overallState = .partialFailure(needsAdmin: true)
                        showingRestartOptions = true
                    } else if touchBarResult.overallSuccess {
                        // Full success
                        flowState = .success(usedAdmin: false)
                        restartProgress.controlStrip = .success
                        restartProgress.touchBarServer = .success
                        restartProgress.displayRefresh = .success
                        restartProgress.overallState = .success
                        showSuccessAlert(usedAdmin: false)
                    } else {
                        // Failure
                        let failedProcesses = touchBarResult.failedProcesses.joined(separator: ", ")
                        flowState = .failure("Failed to restart: \(failedProcesses)")
                        restartProgress.overallState = .failure("Process restart failed")
                    }
                case .failure(let error):
                    flowState = .failure(error.localizedDescription)
                    restartProgress.overallState = .failure(error.localizedDescription)
                }
            }
        }
    }

    /// Simulate progress updates to provide visual feedback during restart
    private func simulateProgressUpdates() async {
        // Control Strip
        await MainActor.run {
            restartProgress.updateStatus(for: "controlStrip", status: .inProgress)
        }
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s

        await MainActor.run {
            restartProgress.updateStatus(for: "controlStrip", status: .success)
            restartProgress.updateStatus(for: "touchBarServer", status: .inProgress)
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

        await MainActor.run {
            restartProgress.updateStatus(for: "touchBarServer", status: .success)
            restartProgress.updateStatus(for: "displayRefresh", status: .inProgress)
        }
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        await MainActor.run {
            restartProgress.updateStatus(for: "displayRefresh", status: .success)
        }
    }

    private func handleProgressComplete(_ state: OverallRestartState) {
        switch state {
        case .success:
            flowState = .success(usedAdmin: false)
        case .partialFailure(let needsAdmin):
            flowState = .partialFailure(needsAdmin: needsAdmin)
            if needsAdmin {
                showingRestartOptions = true
            }
        case .failure(let message):
            flowState = .failure(message)
        default:
            break
        }
    }

    private func handleGrantAdmin() {
        showingRestartOptions = false
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
                        showingRestartOptions = true
                    } else {
                        flowState = .failure(error.localizedDescription)
                        restartProgress.overallState = .failure(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func handleRestartComputer() {
        showingRestartOptions = false

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
        showingRestartOptions = false
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