import SwiftUI

/// Right panel showing context-specific content based on the current flow state.
/// Provides explanations, action buttons, and user guidance.
struct ContextPanelView: View {
    let flowState: ContentViewFlowState

    // Action callbacks
    let onGrantAdmin: () -> Void
    let onRestartComputer: () -> Void
    let onCancel: () -> Void
    let onDone: () -> Void
    let onTryAgain: () -> Void
    let onShare: () -> Void

    @State private var hoveredButton: ButtonType?

    private enum ButtonType {
        case primary, secondary, tertiary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - fixed at top
            headerSection
                .padding(.bottom, 16)

            // Scrollable content area
            ScrollView(.vertical, showsIndicators: false) {
                contentSection
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Action buttons - fixed at bottom
            actionSection
                .padding(.top, 16)
        }
        .padding(24)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .animation(.easeInOut(duration: 0.3), value: flowState)
    }

    // MARK: - Header Section

    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: headerIcon)
                .font(.system(size: 28))
                .foregroundColor(headerColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(headerTitle)
                    .font(.system(.title3, design: .default, weight: .semibold))
                    .foregroundColor(.primary)

                if let subtitle = headerSubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var headerIcon: String {
        switch flowState {
        case .idle:
            return "wrench.and.screwdriver"
        case .restarting:
            return "gearshape.2"
        case .success:
            return "checkmark.seal.fill"
        case .partialFailure:
            return "exclamationmark.triangle.fill"
        case .failure:
            return "xmark.octagon.fill"
        }
    }

    private var headerColor: Color {
        switch flowState {
        case .idle: return .blue
        case .restarting: return .blue
        case .success: return .green
        case .partialFailure: return .orange
        case .failure: return .red
        }
    }

    private var headerTitle: String {
        switch flowState {
        case .idle:
            return "Ready to Fix"
        case .restarting:
            return "Restarting Touch Bar"
        case .success:
            return "Touch Bar Fixed!"
        case .partialFailure:
            return "Admin Access Needed"
        case .failure:
            return "Restart Failed"
        }
    }

    private var headerSubtitle: String? {
        switch flowState {
        case .restarting:
            return "This takes a few seconds..."
        case .success:
            return "All services restarted successfully"
        default:
            return nil
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        switch flowState {
        case .idle:
            idleContent
        case .restarting:
            restartingContent
        case .success:
            successContent
        case .partialFailure:
            adminNeededContent
        case .failure(let message):
            failureContent(message: message)
        }
    }

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What will happen:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Control Strip - UI elements layer")
                bulletPoint("Touch Bar Server - Core functionality")
                bulletPoint("Display Refresh - Graphics rendering")
            }

            Text("This is safe and takes only a few seconds.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }

    private var restartingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's happening:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("TouchBarFix restarts three core Apple services that control your Touch Bar:")
                .font(.callout)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Control Strip - UI elements layer")
                bulletPoint("Touch Bar Server - Core functionality")
                bulletPoint("Display Refresh - Graphics rendering")
            }

            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Please wait...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
    }

    private var successContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Touch Bar services have been successfully restarted.")
                .font(.callout)
                .foregroundColor(.secondary)

            Text("Your Touch Bar should now be fully responsive. If you still experience issues, try a full Mac restart.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var adminNeededContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Why admin is necessary
            explanationBlock(
                title: "Why admin is necessary:",
                content: "Touch Bar Server runs as root. Normal users can't restart root processes without permission."
            )

            // Why it's safe
            explanationBlock(
                title: "Why it's safe:",
                content: "TouchBarFix only restarts Apple's built-in Touch Bar processes. No data is modified."
            )

            // Alternative
            explanationBlock(
                title: "Alternative:",
                content: "A Mac restart will restart all services without admin access."
            )
        }
    }

    private func failureContent(message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The following issues occurred:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(message)
                .font(.callout)
                .foregroundColor(.red)
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)

            Text("Troubleshooting steps:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 6) {
                numberedPoint(1, "Try restarting the Touch Bar again")
                numberedPoint(2, "Restart your Mac manually")
                numberedPoint(3, "Contact support if issue persists")
            }
        }
    }

    // MARK: - Action Section

    @ViewBuilder
    private var actionSection: some View {
        switch flowState {
        case .idle:
            EmptyView()

        case .restarting:
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.cancelAction)
                Spacer()
            }

        case .success:
            HStack(spacing: 12) {
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .scaleEffect(hoveredButton == .primary ? 1.02 : 1.0)
                .onHover { hoveredButton = $0 ? .primary : nil }

                Button(action: onShare) {
                    Text("Tell a Friend")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

        case .partialFailure:
            adminActionButtons

        case .failure:
            failureActionButtons
        }
    }

    private var adminActionButtons: some View {
        VStack(spacing: 8) {
            // Primary: Grant Admin
            Button(action: onGrantAdmin) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.body)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Grant Admin Access")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("(Recommended)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
            .scaleEffect(hoveredButton == .primary ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: hoveredButton)
            .onHover { hoveredButton = $0 ? .primary : nil }

            // Secondary: Restart Mac
            Button(action: onRestartComputer) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.body)

                    Text("Restart Mac")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color(NSColor.controlBackgroundColor))
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .scaleEffect(hoveredButton == .secondary ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: hoveredButton)
            .onHover { hoveredButton = $0 ? .secondary : nil }

            // Tertiary: Cancel (proper button, left-aligned)
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.cancelAction)
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    private var failureActionButtons: some View {
        VStack(spacing: 10) {
            Button(action: onTryAgain) {
                Text("Try Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
            .scaleEffect(hoveredButton == .primary ? 1.02 : 1.0)
            .onHover { hoveredButton = $0 ? .primary : nil }

            HStack {
                Button("Close", action: onCancel)
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.cancelAction)
                Spacer()
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helper Views

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.secondary)
            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }

    private func numberedPoint(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number).")
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(width: 16, alignment: .trailing)
            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }

    private func explanationBlock(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(content)
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContextPanelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContextPanelView(
                flowState: .idle,
                onGrantAdmin: {},
                onRestartComputer: {},
                onCancel: {},
                onDone: {},
                onTryAgain: {},
                onShare: {}
            )
            .frame(width: 400, height: 400)
            .background(Color(NSColor.windowBackgroundColor))
            .previewDisplayName("Idle")

            ContextPanelView(
                flowState: .partialFailure(needsAdmin: true),
                onGrantAdmin: {},
                onRestartComputer: {},
                onCancel: {},
                onDone: {},
                onTryAgain: {},
                onShare: {}
            )
            .frame(width: 400, height: 400)
            .background(Color(NSColor.windowBackgroundColor))
            .previewDisplayName("Needs Admin")
        }
    }
}
#endif
