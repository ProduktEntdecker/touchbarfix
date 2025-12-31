import Foundation
import StoreKit

/// Manages smart review requests to maximize App Store ratings
class ReviewRequestManager: ObservableObject {
    private let userDefaults: UserDefaults

    // Keys for tracking review requests
    private let reviewRequestedKey = "reviewRequested"
    private let lastReviewRequestKey = "lastReviewRequest"
    private let reviewPromptCountKey = "reviewPromptCount"
    private let userDeclinedReviewKey = "userDeclinedReview"

    /// Initialize with optional dependency injection for testing
    /// - Parameter userDefaults: UserDefaults instance (defaults to .standard)
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Smart logic for when to request reviews
    func shouldRequestReview(afterSuccessfulFix fixCount: Int) -> Bool {
        let reviewRequested = userDefaults.bool(forKey: reviewRequestedKey)
        let userDeclined = userDefaults.bool(forKey: userDeclinedReviewKey)
        let promptCount = userDefaults.integer(forKey: reviewPromptCountKey)
        let lastRequestDate = userDefaults.object(forKey: lastReviewRequestKey) as? Date

        // Don't prompt if user already left a review or explicitly declined
        if reviewRequested || userDeclined {
            return false
        }

        // Don't prompt too frequently (max 2 prompts ever)
        if promptCount >= 2 {
            return false
        }

        // Don't prompt too soon after last request
        if let lastRequest = lastRequestDate,
           Date().timeIntervalSince(lastRequest) < 2_592_000 { // 30 days
            return false
        }

        // Trigger conditions:
        // 1. After 2nd successful fix (user has proven value)
        // 2. After 5th fix (for power users)
        // 3. After 10th fix (for super users, if somehow we missed earlier)
        let triggerCounts = [2, 5, 10]

        return triggerCounts.contains(fixCount)
    }

    /// Request App Store review (macOS approach)
    func requestAppStoreReview() {
        // For macOS, we use the direct approach since SKStoreReviewController
        // scene-based API is primarily for iOS
        requestReviewFallback()

        // Track that we made a request
        recordReviewRequest()
    }

    /// Fallback: Direct App Store review page
    private func requestReviewFallback() {
        // This will need to be updated with actual App Store ID when published
        let appStoreReviewURL = "https://apps.apple.com/app/id[TOUCHBARFIX_APP_ID]?action=write-review"

        if let url = URL(string: appStoreReviewURL) {
            NSWorkspace.shared.open(url)
        } else {
            // Ultimate fallback: open TouchBarFix website
            if let fallbackURL = URL(string: "https://touchbarfix.com/review") {
                NSWorkspace.shared.open(fallbackURL)
            }
        }
    }

    /// For manual review requests (user clicks "Leave Review" button)
    func requestReview() {
        requestReviewFallback() // Always use direct link for manual requests
        recordReviewRequest()
    }

    func recordReviewRequest() {
        let currentCount = userDefaults.integer(forKey: reviewPromptCountKey)
        userDefaults.set(currentCount + 1, forKey: reviewPromptCountKey)
        userDefaults.set(Date(), forKey: lastReviewRequestKey)
    }

    /// Call this if user completes a review (detected via App Store Connect API)
    func markReviewCompleted() {
        userDefaults.set(true, forKey: reviewRequestedKey)
    }

    /// Call this if user explicitly declines to review
    func markReviewDeclined() {
        userDefaults.set(true, forKey: userDeclinedReviewKey)
    }

    /// Check if we should show a manual "Leave Review" button
    func shouldShowReviewButton() -> Bool {
        let userDeclined = userDefaults.bool(forKey: userDeclinedReviewKey)
        let reviewRequested = userDefaults.bool(forKey: reviewRequestedKey)

        // Show button if user hasn't declined and hasn't already reviewed
        return !userDeclined && !reviewRequested
    }

    /// Generate contextual review request messages
    func getReviewRequestMessage(fixCount: Int) -> String {
        switch fixCount {
        case 2:
            return "TouchBarFix has saved your day twice! Mind leaving a quick review to help other MacBook users discover this fix?"
        case 5:
            return "You're a TouchBarFix power user with 5 successful fixes! A review would help us reach more MacBook users who need this."
        case 10:
            return "Incredible! 10+ successful fixes. You've definitely proven TouchBarFix works. Would you share your experience in a review?"
        default:
            return "Loving TouchBarFix? A review helps other MacBook users discover this essential tool!"
        }
    }

    /// Get the prompt count for testing
    var promptCount: Int {
        userDefaults.integer(forKey: reviewPromptCountKey)
    }

    /// Get whether review was requested for testing
    var reviewRequested: Bool {
        userDefaults.bool(forKey: reviewRequestedKey)
    }

    /// Get whether user declined for testing
    var userDeclined: Bool {
        userDefaults.bool(forKey: userDeclinedReviewKey)
    }
}

/// Extension to handle macOS-specific review request logic
extension ReviewRequestManager {

    /// Check if system supports native review prompts
    var supportsNativeReviewPrompt: Bool {
        if #available(macOS 12.0, *) {
            return true
        }
        return false
    }

    /// Get the optimal review request timing based on user behavior
    func getOptimalReviewTiming() -> TimeInterval {
        // Request review 3 seconds after successful fix to let user feel the success
        return 3.0
    }
}
