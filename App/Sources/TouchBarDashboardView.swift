import SwiftUI

/// Dashboard layout for Touch Bar restart process.
/// Shows status panel on the left (always visible) and context panel on the right.
struct TouchBarDashboardView: View {
    @ObservedObject var progress: RestartProgress

    /// Current flow state
    let flowState: ContentViewFlowState

    /// Callbacks for user actions
    let onGrantAdmin: () -> Void
    let onRestartComputer: () -> Void
    let onCancel: () -> Void
    let onDone: () -> Void
    let onTryAgain: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // LEFT: Status Panel - Always visible
            StatusPanelView(progress: progress)
                .frame(width: 220)

            // Divider
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)

            // RIGHT: Context Panel - Changes based on state
            ContextPanelView(
                flowState: flowState,
                onGrantAdmin: onGrantAdmin,
                onRestartComputer: onRestartComputer,
                onCancel: onCancel,
                onDone: onDone,
                onTryAgain: onTryAgain,
                onShare: onShare
            )
            .frame(maxWidth: .infinity)
        }
        .frame(width: 640, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Status Panel (Left Side)

/// Left panel showing process status - always visible during restart flow
struct StatusPanelView: View {
    @ObservedObject var progress: RestartProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Status")
                .font(.system(.title3, design: .default, weight: .semibold))
                .foregroundColor(.primary)

            // Process list
            VStack(spacing: 8) {
                ForEach(progress.processes) { process in
                    CompactProcessRow(process: process)
                }
            }

            Spacer()

            // Overall status summary
            statusSummary
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
    }

    @ViewBuilder
    private var statusSummary: some View {
        HStack(spacing: 8) {
            Image(systemName: summaryIcon)
                .foregroundColor(summaryColor)

            Text(summaryText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(summaryColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var summaryIcon: String {
        switch progress.overallState {
        case .idle:
            return "circle.dashed"
        case .restarting:
            return "arrow.triangle.2.circlepath"
        case .success:
            return "checkmark.seal.fill"
        case .partialFailure:
            return "exclamationmark.triangle.fill"
        case .failure:
            return "xmark.octagon.fill"
        }
    }

    private var summaryColor: Color {
        switch progress.overallState {
        case .idle:
            return .gray
        case .restarting:
            return .blue
        case .success:
            return .green
        case .partialFailure:
            return .orange
        case .failure:
            return .red
        }
    }

    private var summaryText: String {
        switch progress.overallState {
        case .idle:
            return "Ready"
        case .restarting:
            return "In Progress..."
        case .success:
            return "All Complete"
        case .partialFailure:
            return "Partial Success"
        case .failure:
            return "Failed"
        }
    }
}

// MARK: - Compact Process Row

/// Compact version of process status row for the left panel
struct CompactProcessRow: View {
    let process: UIProcessInfo
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 10) {
            statusIndicator
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(process.displayName)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundColor(.primary)

                Text(statusText)
                    .font(.caption2)
                    .foregroundColor(statusColor)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(backgroundColor)
        .cornerRadius(6)
        .onAppear {
            if case .inProgress = process.status {
                isPulsing = true
            }
        }
        .onChange(of: process.status) { newStatus in
            isPulsing = (newStatus == .inProgress)
        }
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch process.status {
        case .pending:
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
        case .inProgress:
            Circle()
                .fill(Color.blue)
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
                .font(.system(size: 14, weight: .semibold))
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14, weight: .semibold))
        }
    }

    private var statusText: String {
        switch process.status {
        case .pending:
            return "Waiting..."
        case .inProgress:
            return "Restarting..."
        case .success:
            return "Complete"
        case .failed(let reason):
            return reason == .needsAdmin ? "Needs Admin" : "Failed"
        }
    }

    private var statusColor: Color {
        switch process.status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .success: return .green
        case .failed: return .red
        }
    }

    private var backgroundColor: Color {
        switch process.status {
        case .pending: return Color.gray.opacity(0.05)
        case .inProgress: return Color.blue.opacity(0.1)
        case .success: return Color.green.opacity(0.1)
        case .failed: return Color.red.opacity(0.1)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TouchBarDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Restarting state
            TouchBarDashboardView(
                progress: {
                    let p = RestartProgress()
                    p.controlStrip = .success
                    p.touchBarServer = .inProgress
                    p.displayRefresh = .pending
                    p.overallState = .restarting
                    return p
                }(),
                flowState: .restarting,
                onGrantAdmin: {},
                onRestartComputer: {},
                onCancel: {},
                onDone: {},
                onTryAgain: {},
                onShare: {}
            )
            .previewDisplayName("Restarting")

            // Needs admin
            TouchBarDashboardView(
                progress: {
                    let p = RestartProgress()
                    p.controlStrip = .success
                    p.touchBarServer = .failed(reason: .needsAdmin)
                    p.displayRefresh = .success
                    p.overallState = .partialFailure(needsAdmin: true)
                    return p
                }(),
                flowState: .partialFailure(needsAdmin: true),
                onGrantAdmin: {},
                onRestartComputer: {},
                onCancel: {},
                onDone: {},
                onTryAgain: {},
                onShare: {}
            )
            .previewDisplayName("Needs Admin")

            // Success
            TouchBarDashboardView(
                progress: {
                    let p = RestartProgress()
                    p.controlStrip = .success
                    p.touchBarServer = .success
                    p.displayRefresh = .success
                    p.overallState = .success
                    return p
                }(),
                flowState: .success(usedAdmin: false),
                onGrantAdmin: {},
                onRestartComputer: {},
                onCancel: {},
                onDone: {},
                onTryAgain: {},
                onShare: {}
            )
            .previewDisplayName("Success")
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
#endif
