import Foundation
import SwiftUI

/// Protocol for network session to enable dependency injection
protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}

/// Privacy-first analytics service for TouchBarFix
class AnalyticsService: ObservableObject {
    @Published var totalFixesGlobal: Int = 0
    @Published var successRate: Double = 0.98  // Start with high confidence
    @Published var userFixCount: Int = 0

    private let endpoint = "https://api.touchbarfix.com/analytics"
    private let userDefaults: UserDefaults
    private let session: NetworkSession

    // Keys for local storage
    private let userFixCountKey = "userTotalFixes"
    private let lastStatsUpdateKey = "lastStatsUpdate"
    private let cachedGlobalFixesKey = "cachedGlobalFixes"
    private let cachedSuccessRateKey = "cachedSuccessRate"
    static let analyticsEnabledKey = "analyticsEnabled"

    /// Initialize with optional dependency injection for testing
    /// - Parameters:
    ///   - session: Network session (defaults to URLSession.shared)
    ///   - userDefaults: UserDefaults instance (defaults to .standard)
    ///   - skipInitialFetch: Skip fetching global stats on init (useful for tests)
    init(
        session: NetworkSession = URLSession.shared,
        userDefaults: UserDefaults = .standard,
        skipInitialFetch: Bool = false
    ) {
        self.session = session
        self.userDefaults = userDefaults
        loadLocalData()
        if !skipInitialFetch {
            fetchGlobalStats() // Non-blocking background fetch
        }
    }

    /// Check if analytics are enabled by user
    var analyticsEnabled: Bool {
        userDefaults.bool(forKey: Self.analyticsEnabledKey)
    }

    /// PRIVACY-COMPLIANT: Only tracks success metrics, no personal data
    func trackFixAttempt(success: Bool, modelIdentifier: String) async {
        // Respect user's analytics preference
        guard analyticsEnabled else {
            print("📊 Analytics disabled by user - not tracking")
            return
        }
        // Update local counters
        await MainActor.run {
            if success {
                userFixCount += 1
                userDefaults.set(userFixCount, forKey: userFixCountKey)
            }
        }

        // Create anonymized analytics payload
        let anonymizedModel = String(modelIdentifier.prefix(12)) // Only model series, not serial
        let payload: [String: Any] = [
            "event": "touchbar_fix",
            "success": success,
            "model_series": anonymizedModel,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "app_version": "1.3.0",
            // NO personal identifiers, IP is not stored server-side
        ]

        // Submit analytics (fire-and-forget, don't block UI)
        await submitAnalytics(payload)

        // Update global stats optimistically
        await MainActor.run {
            if success {
                totalFixesGlobal += 1
                // Cache the updated count
                userDefaults.set(totalFixesGlobal, forKey: cachedGlobalFixesKey)
            }
        }
    }

    func submitAnalytics(_ data: [String: Any]) async {
        guard let url = URL(string: endpoint) else { return }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("TouchBarFix/1.3.0", forHTTPHeaderField: "User-Agent")

            request.httpBody = try JSONSerialization.data(withJSONObject: data)

            // Set timeout to prevent hanging
            request.timeoutInterval = 10

            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                print("📊 Analytics submitted successfully")
            }
        } catch {
            // Fail silently - analytics shouldn't impact user experience
            print("📊 Analytics submission failed (non-blocking): \(error)")
        }
    }

    private func fetchGlobalStats() {
        Task {
            await updateGlobalStats()
        }
    }

    func updateGlobalStats() async {
        // Check if we need to update (don't spam the API)
        let lastUpdate = userDefaults.object(forKey: lastStatsUpdateKey) as? Date ?? Date.distantPast
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdate) / 3600

        if hoursSinceUpdate < 6 { // Update max every 6 hours
            return
        }

        guard let url = URL(string: "\(endpoint)/stats") else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("TouchBarFix/1.3.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 15

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let stats = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }

            await MainActor.run {
                if let totalFixes = stats["total_fixes"] as? Int,
                   let successRate = stats["success_rate"] as? Double {
                    self.totalFixesGlobal = max(totalFixes, self.totalFixesGlobal) // Never decrease
                    self.successRate = successRate

                    // Cache the results
                    userDefaults.set(totalFixes, forKey: cachedGlobalFixesKey)
                    userDefaults.set(successRate, forKey: cachedSuccessRateKey)
                    userDefaults.set(Date(), forKey: lastStatsUpdateKey)
                }
            }

        } catch {
            print("📊 Global stats fetch failed (non-blocking): \(error)")
        }
    }

    private func loadLocalData() {
        userFixCount = userDefaults.integer(forKey: userFixCountKey)

        // Load cached global stats
        let cachedFixes = userDefaults.integer(forKey: cachedGlobalFixesKey)
        if cachedFixes > 0 {
            totalFixesGlobal = cachedFixes
        }

        let cachedRate = userDefaults.double(forKey: cachedSuccessRateKey)
        if cachedRate > 0 {
            successRate = cachedRate
        }
    }

    /// Generate social proof messages based on actual data
    func getSuccessMessage() -> String {
        if totalFixesGlobal >= 10000 {
            return "Join \(formatLargeNumber(totalFixesGlobal))+ users who fixed their Touch Bar!"
        } else if totalFixesGlobal >= 1000 {
            return "\(formatLargeNumber(totalFixesGlobal))+ successful Touch Bar fixes and counting!"
        } else if totalFixesGlobal >= 100 {
            return "\(totalFixesGlobal)+ MacBook users have fixed their Touch Bar"
        } else {
            return "Helping MacBook users fix unresponsive Touch Bars"
        }
    }

    /// Format large numbers for display (e.g., 15000 -> "15k")
    func formatLargeNumber(_ number: Int) -> String {
        if number >= 10000 {
            return "\(number / 1000)k"
        }
        return "\(number)"
    }
}
