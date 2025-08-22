import SwiftUI

// Social proof stats view for TouchBarFix
struct StatsView: View {
    let analyticsService: AnalyticsService
    let onDismiss: () -> Void
    
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("TouchBarFix Impact")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Real data from MacBook users worldwide")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                
                // Total fixes
                StatCard(
                    title: "Total Fixes",
                    value: formatLargeNumber(analyticsService.totalFixesGlobal),
                    subtitle: "Touch Bars restored",
                    icon: "wrench.and.screwdriver.fill",
                    color: .blue,
                    animateNumbers: $animateNumbers
                )
                
                // Success rate
                StatCard(
                    title: "Success Rate",
                    value: "\(Int(analyticsService.successRate * 100))%",
                    subtitle: "Fix success rate",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    animateNumbers: $animateNumbers
                )
                
                // Your contribution
                StatCard(
                    title: "Your Fixes",
                    value: "\(analyticsService.userFixCount)",
                    subtitle: "Times you've used TouchBarFix",
                    icon: "person.fill",
                    color: .orange,
                    animateNumbers: $animateNumbers
                )
                
                // Average fix time
                StatCard(
                    title: "Avg Fix Time",
                    value: "~3 sec",
                    subtitle: "From click to working Touch Bar",
                    icon: "clock.fill",
                    color: .purple,
                    animateNumbers: $animateNumbers
                )
            }
            
            // Social proof message
            VStack(spacing: 12) {
                Text(analyticsService.getSuccessMessage())
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                // Call to action
                if analyticsService.userFixCount > 0 {
                    Text("Love TouchBarFix? Help other MacBook users discover it!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                Button("Share TouchBarFix") {
                    // This could trigger the share flow
                    if let url = URL(string: "https://touchbarfix.com?utm_source=stats_view") {
                        NSWorkspace.shared.open(url)
                    }
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Close") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .frame(width: 480, height: 520)
        .background(Color.white)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateNumbers = true
            }
        }
    }
    
    private func formatLargeNumber(_ number: Int) -> String {
        if number >= 100000 {
            return "\(number / 1000)k+"
        } else if number >= 10000 {
            return "\(number / 1000)k+"
        } else if number >= 1000 {
            return "\(String(format: "%.1f", Double(number) / 1000))k+"
        } else {
            return "\(number)+"
        }
    }
}

// Individual stat card component
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var animateNumbers: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .scaleEffect(animateNumbers ? 1.0 : 0.8)
                .opacity(animateNumbers ? 1.0 : 0.3)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateNumbers)
            
            // Title and subtitle
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    StatsView(
        analyticsService: {
            let service = AnalyticsService()
            service.totalFixesGlobal = 12847
            service.successRate = 0.984
            service.userFixCount = 5
            return service
        }(),
        onDismiss: {}
    )
}