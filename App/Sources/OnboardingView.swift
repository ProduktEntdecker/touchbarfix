import SwiftUI

// Simple onboarding for new viral features in TouchBarFix
struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var analyticsEnabled = true
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to TouchBarFix 1.3!",
            subtitle: "New features to help you and other MacBook users",
            icon: "sparkles",
            color: .blue,
            description: "We've added smart sharing and analytics to help the MacBook community discover TouchBarFix when they need it most."
        ),
        OnboardingPage(
            title: "Smart Review Requests",
            subtitle: "Help us reach more users who need TouchBarFix",
            icon: "star.fill",
            color: .orange,
            description: "After successful fixes, we may ask for an App Store review. This helps other MacBook users discover TouchBarFix when their Touch Bar breaks."
        ),
        OnboardingPage(
            title: "Share Your Success",
            subtitle: "Turn your fix into help for others",
            icon: "square.and.arrow.up.fill",
            color: .green,
            description: "When TouchBarFix saves your day, you can share it on Twitter, LinkedIn, or with friends. Every share helps another frustrated MacBook user."
        ),
        OnboardingPage(
            title: "Privacy-First Analytics",
            subtitle: "Anonymous data helps everyone",
            icon: "shield.checkered",
            color: .purple,
            description: "We track fix success rates anonymously to show social proof and improve the app. No personal data, no tracking, just better TouchBarFix for everyone."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(currentPage >= index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Content - Use simple view switching for macOS compatibility
            OnboardingPageView(page: pages[currentPage])
                .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Special analytics consent for last page
            if currentPage == pages.count - 1 {
                VStack(spacing: 16) {
                    HStack {
                        Toggle("Enable anonymous analytics", isOn: $analyticsEnabled)
                            .toggleStyle(SwitchToggleStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    Text("You can change this anytime in app settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 12)
            }
            
            // Navigation
            HStack {
                Button("Skip") {
                    completeOnboarding()
                }
                .opacity(currentPage > 0 ? 0 : 1)
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
        }
        .frame(width: 450, height: 550)
        .background(Color.white)
    }
    
    private func completeOnboarding() {
        // Save analytics preference
        UserDefaults.standard.set(analyticsEnabled, forKey: "analyticsEnabled")
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        onComplete()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 64))
                .foregroundColor(page.color)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.vertical, 40)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}