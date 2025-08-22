import Foundation
import SwiftUI

// Manages viral sharing functionality for TouchBarFix
class SharingManager: ObservableObject {
    
    // Generate platform-specific share content
    func generateShareContent(fixCount: Int, modelIdentifier: String) -> ShareContent {
        let modelSeries = getModelSeries(modelIdentifier)
        
        let content = ShareContent(
            title: getShareTitle(fixCount: fixCount),
            message: getShareMessage(fixCount: fixCount, modelSeries: modelSeries),
            url: generateTrackingURL(source: "app_share"),
            hashtags: ["MacBook", "TouchBar", "MacTips", "ProductivityHack"],
            platform: .general
        )
        
        return content
    }
    
    // Share to macOS native sharing
    func shareToSystem(content: ShareContent, sourceView: NSView?) {
        let items: [Any] = [content.message, content.url]
        
        let sharingServicePicker = NSSharingServicePicker(items: items)
        
        if let view = sourceView {
            sharingServicePicker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        } else {
            // Fallback: show from app's main window
            if let window = NSApplication.shared.mainWindow,
               let contentView = window.contentView {
                sharingServicePicker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
            }
        }
    }
    
    // Platform-specific sharing
    func shareToTwitter(fixCount: Int, modelSeries: String) {
        let tweetContent = getTwitterContent(fixCount: fixCount, modelSeries: modelSeries)
        let encodedTweet = tweetContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedTweet)") {
            NSWorkspace.shared.open(url)
            
            // Track sharing event
            trackShareEvent(platform: .twitter)
        }
    }
    
    func shareToLinkedIn(fixCount: Int) {
        let _ = getLinkedInContent(fixCount: fixCount) // Content not used in direct URL sharing
        let trackingURL = generateTrackingURL(source: "linkedin")
        
        // LinkedIn sharing uses their sharing API
        let shareURL = "https://www.linkedin.com/sharing/share-offsite/?url=\(trackingURL.absoluteString)"
        
        if let url = URL(string: shareURL) {
            NSWorkspace.shared.open(url)
            trackShareEvent(platform: .linkedin)
        }
    }
    
    func copyToClipboard(fixCount: Int, modelSeries: String) {
        let content = generateShareContent(fixCount: fixCount, modelIdentifier: modelSeries)
        let fullText = "\(content.message)\n\n\(content.url.absoluteString)"
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(fullText, forType: .string)
        
        trackShareEvent(platform: .clipboard)
    }
    
    // MARK: - Content Generation
    
    private func getShareTitle(fixCount: Int) -> String {
        if fixCount == 1 {
            return "Fixed My Touch Bar!"
        } else if fixCount < 5 {
            return "TouchBarFix Saves the Day Again!"
        } else {
            return "TouchBarFix: The Essential MacBook Tool"
        }
    }
    
    private func getShareMessage(fixCount: Int, modelSeries: String) -> String {
        let messages = [
            1: "Just saved my \(modelSeries) from an unresponsive Touch Bar! TouchBarFix fixed it instantly. 🔧✨",
            2: "TouchBarFix has rescued my Touch Bar twice now! Every MacBook Pro owner needs this. 💪",
            3: "Third time TouchBarFix has saved me from Touch Bar frustration. This app is essential! 🚀",
            5: "TouchBarFix: 5 successful fixes and counting! Best productivity tool for MacBook users. ⭐️",
            10: "TouchBarFix has fixed my Touch Bar 10+ times. Absolute lifesaver for any MacBook Pro user! 🏆"
        ]
        
        // Find the appropriate message based on fix count
        let messageFixCount = messages.keys.sorted().last { $0 <= fixCount } ?? 1
        
        return messages[messageFixCount] ?? messages[1]!
    }
    
    private func getTwitterContent(fixCount: Int, modelSeries: String) -> String {
        let message = getShareMessage(fixCount: fixCount, modelSeries: modelSeries)
        let url = generateTrackingURL(source: "twitter")
        let hashtags = "#MacBook #TouchBar #ProductivityHack"
        
        // Twitter has 280 char limit, so we need to be concise
        return "\(message)\n\n\(url.absoluteString) \(hashtags)"
    }
    
    private func getLinkedInContent(fixCount: Int) -> String {
        return """
        Just discovered TouchBarFix - a simple but powerful tool that instantly fixes unresponsive MacBook Touch Bars.
        
        As someone who relies on their MacBook for productivity, this has been a game-changer. \(fixCount) successful fixes and counting!
        
        Perfect example of how the right tool can solve a frustrating problem in seconds. Highly recommend for any MacBook Pro user.
        """
    }
    
    // MARK: - Utility Functions
    
    private func getModelSeries(_ modelIdentifier: String) -> String {
        if modelIdentifier.contains("MacBookPro13") { return "MacBook Pro 13\" (2016)" }
        if modelIdentifier.contains("MacBookPro14") { return "MacBook Pro (2017)" }
        if modelIdentifier.contains("MacBookPro15") { return "MacBook Pro (2018-19)" }
        if modelIdentifier.contains("MacBookPro16") { return "MacBook Pro (2019-20)" }
        if modelIdentifier.contains("MacBookPro17") { return "MacBook Pro M1" }
        if modelIdentifier.contains("MacBookPro18") { return "MacBook Pro M1 Pro/Max" }
        return "MacBook Pro"
    }
    
    private func generateTrackingURL(source: String) -> URL {
        let baseURL = "https://touchbarfix.com"
        let utm = "?utm_source=app&utm_medium=social&utm_campaign=user_share&utm_content=\(source)"
        
        return URL(string: "\(baseURL)\(utm)") ?? URL(string: baseURL)!
    }
    
    private func trackShareEvent(platform: SharingPlatform) {
        // Track sharing events for analytics (privacy-compliant)
        let eventData: [String: Any] = [
            "event": "user_share",
            "platform": platform.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "app_version": "1.3.0"
        ]
        
        // Submit to analytics (non-blocking)
        Task.detached {
            await self.submitShareAnalytics(eventData)
        }
    }
    
    private func submitShareAnalytics(_ data: [String: Any]) async {
        // Same analytics endpoint as main service
        guard let url = URL(string: "https://api.touchbarfix.com/analytics") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("TouchBarFix/1.3.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                print("📤 Share event tracked: \(data["platform"] ?? "unknown")")
            }
        } catch {
            print("📤 Share tracking failed (non-blocking): \(error)")
        }
    }
}

// MARK: - Data Models

struct ShareContent {
    let title: String
    let message: String
    let url: URL
    let hashtags: [String]
    let platform: SharingPlatform
}

enum SharingPlatform: String, CaseIterable {
    case general = "general"
    case twitter = "twitter"
    case linkedin = "linkedin"
    case clipboard = "clipboard"
    case messages = "messages"
    case mail = "mail"
    
    var displayName: String {
        switch self {
        case .general: return "Share"
        case .twitter: return "Twitter/X"
        case .linkedin: return "LinkedIn"
        case .clipboard: return "Copy Link"
        case .messages: return "Messages"
        case .mail: return "Email"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "square.and.arrow.up"
        case .twitter: return "text.bubble"
        case .linkedin: return "person.2"
        case .clipboard: return "doc.on.clipboard"
        case .messages: return "message"
        case .mail: return "envelope"
        }
    }
}