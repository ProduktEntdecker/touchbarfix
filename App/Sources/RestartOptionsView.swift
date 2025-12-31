import SwiftUI

/// A dialog view presenting options when Touch Bar restart fails and requires elevated privileges.
/// Follows Nielsen Heuristics for error recovery and user control.
struct RestartOptionsView: View {
    /// Called when user chooses to grant admin access
    let onGrantAdmin: () -> Void
    /// Called when user chooses to restart computer
    let onRestartComputer: () -> Void
    /// Called when user cancels the dialog
    let onCancel: () -> Void

    @State private var hoveredButton: ButtonType? = nil

    private enum ButtonType {
        case grantAdmin
        case restartComputer
    }

    var body: some View {
        VStack(spacing: 24) {
            // Warning Header
            headerSection

            // Explanation
            explanationSection

            // Action Buttons
            actionButtonsSection

            // Cancel Button
            cancelButtonSection
        }
        .padding(32)
        .frame(width: 400, height: 340)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
                .accessibilityHidden(true)

            Text("Additional Step Required")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: - Explanation Section

    private var explanationSection: some View {
        Text("The main Touch Bar service requires administrator access to restart.")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Primary: Grant Admin Access (Recommended)
            Button(action: onGrantAdmin) {
                HStack(spacing: 10) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grant Admin Access")
                            .font(.headline)
                        Text("(Recommended)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .scaleEffect(hoveredButton == .grantAdmin ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: hoveredButton)
            .onHover { isHovered in
                hoveredButton = isHovered ? .grantAdmin : nil
            }
            .keyboardShortcut(.defaultAction) // Enter key activates this button
            .accessibilityHint("This will prompt for your administrator password to restart the Touch Bar service.")

            // Secondary: Restart Computer
            Button(action: onRestartComputer) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)

                    Text("Restart Computer")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .scaleEffect(hoveredButton == .restartComputer ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: hoveredButton)
            .onHover { isHovered in
                hoveredButton = isHovered ? .restartComputer : nil
            }
            .accessibilityHint("This will restart your entire computer to reset all system services including the Touch Bar.")
        }
    }

    // MARK: - Cancel Button Section

    private var cancelButtonSection: some View {
        Button(action: onCancel) {
            Text("Cancel")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction) // Escape key activates this button
        .accessibilityHint("Close this dialog without taking any action.")
    }
}

// MARK: - Preview

#Preview("RestartOptionsView") {
    RestartOptionsView(
        onGrantAdmin: { print("Grant admin tapped") },
        onRestartComputer: { print("Restart computer tapped") },
        onCancel: { print("Cancel tapped") }
    )
}

#Preview("RestartOptionsView - Dark Mode") {
    RestartOptionsView(
        onGrantAdmin: {},
        onRestartComputer: {},
        onCancel: {}
    )
    .preferredColorScheme(.dark)
}
