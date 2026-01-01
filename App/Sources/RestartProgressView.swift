import SwiftUI
import Combine

// MARK: - Data Models

/// Represents the UI display status of an individual process during restart
/// Note: This is different from TouchBarManager.ProcessRestartStatus which tracks actual process results
enum UIProcessStatus: Equatable {
    case pending
    case inProgress
    case success
    case failed(reason: FailureReason)
}

/// Reasons why a process restart might fail
enum FailureReason: Equatable {
    case needsAdmin
    case notRunning
    case unknown(String)

    var description: String {
        switch self {
        case .needsAdmin:
            return "Administrator privileges required"
        case .notRunning:
            return "Process was not running"
        case .unknown(let message):
            return message
        }
    }
}

/// Represents the overall state of the Touch Bar restart operation
enum OverallRestartState: Equatable {
    case idle
    case restarting
    case success
    case partialFailure(needsAdmin: Bool)
    case failure(String)
}

// MARK: - Process Info

/// Information about a Touch Bar process being restarted (for UI display)
struct UIProcessInfo: Identifiable, Equatable {
    let id: String
    let displayName: String
    var status: UIProcessStatus

    init(id: String, displayName: String, status: UIProcessStatus = .pending) {
        self.id = id
        self.displayName = displayName
        self.status = status
    }
}

// MARK: - RestartProgress Observable

/// Tracks the progress of Touch Bar restart operations
@MainActor
class RestartProgress: ObservableObject {
    @Published var controlStrip: UIProcessStatus = .pending
    @Published var touchBarServer: UIProcessStatus = .pending
    @Published var displayRefresh: UIProcessStatus = .pending
    @Published var overallState: OverallRestartState = .idle

    /// All processes with their current status
    var processes: [UIProcessInfo] {
        [
            UIProcessInfo(id: "controlStrip", displayName: "Control Strip", status: controlStrip),
            UIProcessInfo(id: "touchBarServer", displayName: "Touch Bar Server", status: touchBarServer),
            UIProcessInfo(id: "displayRefresh", displayName: "Display Refresh", status: displayRefresh)
        ]
    }

    /// Reset all statuses to pending
    func reset() {
        controlStrip = .pending
        touchBarServer = .pending
        displayRefresh = .pending
        overallState = .idle
    }

    /// Update the status of a specific process
    func updateStatus(for processId: String, status: UIProcessStatus) {
        switch processId {
        case "controlStrip":
            controlStrip = status
        case "touchBarServer":
            touchBarServer = status
        case "displayRefresh":
            displayRefresh = status
        default:
            break
        }

        updateOverallState()
    }

    /// Update the overall state based on individual process statuses
    private func updateOverallState() {
        let statuses = [controlStrip, touchBarServer, displayRefresh]

        // Check if any are in progress
        if statuses.contains(.inProgress) {
            overallState = .restarting
            return
        }

        // Check if all are pending (not started yet)
        if statuses.allSatisfy({ $0 == .pending }) {
            overallState = .idle
            return
        }

        // Check for failures
        let failures = statuses.compactMap { status -> FailureReason? in
            if case .failed(let reason) = status {
                return reason
            }
            return nil
        }

        if !failures.isEmpty {
            let needsAdmin = failures.contains { $0 == .needsAdmin }
            if statuses.contains(.success) {
                overallState = .partialFailure(needsAdmin: needsAdmin)
            } else {
                let failureMessage = failures.map { $0.description }.joined(separator: ", ")
                overallState = .failure(failureMessage)
            }
            return
        }

        // All succeeded
        if statuses.allSatisfy({ $0 == .success }) {
            overallState = .success
            return
        }

        // Mixed state (some pending, some success) - treat as in-progress
        overallState = .restarting
    }
}

// MARK: - ProcessStatusRow View

/// A reusable row displaying the status of a single process
struct ProcessStatusRow: View {
    let process: UIProcessInfo

    /// Animate pulse effect for in-progress status
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 12) {
            statusIndicator
                .frame(width: 20, height: 20)

            Text(process.displayName)
                .font(.system(.body, design: .default))
                .foregroundColor(.primary)

            Spacer()

            statusText
                .font(.caption)
                .foregroundColor(statusTextColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(8)
        .onAppear {
            if case .inProgress = process.status {
                startPulseAnimation()
            }
        }
        .onChange(of: process.status) { newStatus in
            if case .inProgress = newStatus {
                startPulseAnimation()
            } else {
                isPulsing = false
            }
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch process.status {
        case .pending:
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 16, height: 16)

        case .inProgress:
            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.7 : 1.0)
                .animation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                    value: isPulsing
                )

        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .semibold))

        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16, weight: .semibold))
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch process.status {
        case .pending:
            Text("Waiting...")
                .italic()
        case .inProgress:
            Text("Restarting...")
        case .success:
            Text("Complete")
        case .failed(let reason):
            Text(reason.description)
                .lineLimit(1)
        }
    }

    private var statusTextColor: Color {
        switch process.status {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }

    private var backgroundColor: Color {
        switch process.status {
        case .pending:
            return Color.gray.opacity(0.05)
        case .inProgress:
            return Color.blue.opacity(0.1)
        case .success:
            return Color.green.opacity(0.1)
        case .failed:
            return Color.red.opacity(0.1)
        }
    }

    private func startPulseAnimation() {
        isPulsing = true
    }
}

// MARK: - RestartProgressView

/// Main view displaying real-time progress during Touch Bar restart
struct RestartProgressView: View {
    @ObservedObject var progress: RestartProgress

    /// Optional callback when restart completes
    var onComplete: ((OverallRestartState) -> Void)?

    /// Optional callback to dismiss the view
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerView

            // Process list
            processListView

            // Overall status message
            overallStatusView

            // Action buttons (shown when complete)
            if showActionButtons {
                actionButtonsView
            }
        }
        .padding(24)
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .onChange(of: progress.overallState) { newState in
            handleStateChange(newState)
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: headerIcon)
                .font(.system(size: 32))
                .foregroundColor(headerIconColor)

            Text(headerTitle)
                .font(.headline)
                .foregroundColor(.primary)

            if let subtitle = headerSubtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var processListView: some View {
        VStack(spacing: 8) {
            ForEach(progress.processes) { process in
                ProcessStatusRow(process: process)
            }
        }
    }

    @ViewBuilder
    private var overallStatusView: some View {
        switch progress.overallState {
        case .idle:
            EmptyView()

        case .restarting:
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Please wait...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .success:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Touch Bar restarted successfully!")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

        case .partialFailure(let needsAdmin):
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Partial success")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                if needsAdmin {
                    Text("Some operations require administrator privileges")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

        case .failure(let message):
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.octagon.fill")
                        .foregroundColor(.red)
                    Text("Restart failed")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            if case .failure = progress.overallState {
                Button("Try Again") {
                    progress.reset()
                }
                .buttonStyle(.bordered)
            }

            Button(dismissButtonTitle) {
                onDismiss?()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Computed Properties

    private var showActionButtons: Bool {
        switch progress.overallState {
        case .success, .partialFailure, .failure:
            return true
        default:
            return false
        }
    }

    private var headerIcon: String {
        switch progress.overallState {
        case .idle, .restarting:
            return "wrench.and.screwdriver"
        case .success:
            return "checkmark.circle"
        case .partialFailure:
            return "exclamationmark.triangle"
        case .failure:
            return "xmark.circle"
        }
    }

    private var headerIconColor: Color {
        switch progress.overallState {
        case .idle, .restarting:
            return .blue
        case .success:
            return .green
        case .partialFailure:
            return .orange
        case .failure:
            return .red
        }
    }

    private var headerTitle: String {
        switch progress.overallState {
        case .idle:
            return "Ready to Restart"
        case .restarting:
            return "Restarting Touch Bar..."
        case .success:
            return "Restart Complete"
        case .partialFailure:
            return "Partial Success"
        case .failure:
            return "Restart Failed"
        }
    }

    private var headerSubtitle: String? {
        switch progress.overallState {
        case .restarting:
            return "This may take a few seconds"
        case .success:
            return "Your Touch Bar should now be responsive"
        default:
            return nil
        }
    }

    private var dismissButtonTitle: String {
        switch progress.overallState {
        case .success:
            return "Done"
        case .partialFailure, .failure:
            return "Close"
        default:
            return "Cancel"
        }
    }

    // MARK: - Methods

    private func handleStateChange(_ newState: OverallRestartState) {
        switch newState {
        case .success, .partialFailure, .failure:
            onComplete?(newState)
        default:
            break
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RestartProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Idle state
            RestartProgressView(progress: {
                let p = RestartProgress()
                return p
            }())
            .previewDisplayName("Idle")

            // In progress state
            RestartProgressView(progress: {
                let p = RestartProgress()
                p.controlStrip = .success
                p.touchBarServer = .inProgress
                p.displayRefresh = .pending
                p.overallState = .restarting
                return p
            }())
            .previewDisplayName("In Progress")

            // Success state
            RestartProgressView(progress: {
                let p = RestartProgress()
                p.controlStrip = .success
                p.touchBarServer = .success
                p.displayRefresh = .success
                p.overallState = .success
                return p
            }())
            .previewDisplayName("Success")

            // Partial failure state
            RestartProgressView(progress: {
                let p = RestartProgress()
                p.controlStrip = .success
                p.touchBarServer = .failed(reason: .needsAdmin)
                p.displayRefresh = .success
                p.overallState = .partialFailure(needsAdmin: true)
                return p
            }())
            .previewDisplayName("Partial Failure")

            // Failure state
            RestartProgressView(progress: {
                let p = RestartProgress()
                p.controlStrip = .failed(reason: .notRunning)
                p.touchBarServer = .failed(reason: .unknown("Connection refused"))
                p.displayRefresh = .failed(reason: .needsAdmin)
                p.overallState = .failure("Multiple processes failed")
                return p
            }())
            .previewDisplayName("Failure")
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
#endif
