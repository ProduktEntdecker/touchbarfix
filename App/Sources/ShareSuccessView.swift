import SwiftUI

// Modal view for sharing successful TouchBar fix
struct ShareSuccessView: View {
    let fixCount: Int
    let modelIdentifier: String
    let sharingManager: SharingManager
    let onDismiss: () -> Void
    
    @State private var showingCopyConfirmation = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                
                Text("Share Your Success!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Help other MacBook users discover TouchBarFix")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Success message preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Your message:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                let content = sharingManager.generateShareContent(fixCount: fixCount, modelIdentifier: modelIdentifier)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.message)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(content.url.absoluteString)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
            }
            
            // Sharing options
            VStack(spacing: 16) {
                Text("Choose how to share:")
                    .font(.headline)
                
                // Primary sharing options
                HStack(spacing: 16) {
                    ShareButton(
                        title: "Twitter/X",
                        icon: "text.bubble.fill",
                        color: .blue,
                        action: {
                            let modelSeries = getModelSeries(modelIdentifier)
                            sharingManager.shareToTwitter(fixCount: fixCount, modelSeries: modelSeries)
                            onDismiss()
                        }
                    )
                    
                    ShareButton(
                        title: "LinkedIn",
                        icon: "person.2.fill",
                        color: .blue,
                        action: {
                            sharingManager.shareToLinkedIn(fixCount: fixCount)
                            onDismiss()
                        }
                    )
                    
                    ShareButton(
                        title: "Copy Link",
                        icon: "doc.on.clipboard.fill",
                        color: .green,
                        action: {
                            sharingManager.copyToClipboard(fixCount: fixCount, modelSeries: modelIdentifier)
                            showingCopyConfirmation = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showingCopyConfirmation = false
                                onDismiss()
                            }
                        }
                    )
                }
                
                // Native macOS sharing
                Button(action: {
                    let content = sharingManager.generateShareContent(fixCount: fixCount, modelIdentifier: modelIdentifier)
                    sharingManager.shareToSystem(content: content, sourceView: nil)
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("More Options...")
                    }
                    .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // Dismiss button
            Button("Maybe Later") {
                onDismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(width: 400, height: 500)
        .background(Color.white)
        .overlay(
            // Copy confirmation
            Group {
                if showingCopyConfirmation {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Copied to clipboard!")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        )
    }
    
    private func getModelSeries(_ modelIdentifier: String) -> String {
        if modelIdentifier.contains("MacBookPro13") { return "MacBook Pro 13\" (2016)" }
        if modelIdentifier.contains("MacBookPro14") { return "MacBook Pro (2017)" }
        if modelIdentifier.contains("MacBookPro15") { return "MacBook Pro (2018-19)" }
        if modelIdentifier.contains("MacBookPro16") { return "MacBook Pro (2019-20)" }
        if modelIdentifier.contains("MacBookPro17") { return "MacBook Pro M1" }
        if modelIdentifier.contains("MacBookPro18") { return "MacBook Pro M1 Pro/Max" }
        return "MacBook Pro"
    }
}

// Reusable share button component
struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .cornerRadius(12)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: 80)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                // Subtle hover effect could be added here
            }
        }
    }
}

#Preview {
    ShareSuccessView(
        fixCount: 3,
        modelIdentifier: "MacBookPro15,1",
        sharingManager: SharingManager(),
        onDismiss: {}
    )
}