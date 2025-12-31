import Foundation

/// Centralized MacBook model identification utility
/// Converts model identifiers (e.g., "MacBookPro18,3") to human-readable names
struct MacBookModel {

    /// Convert a model identifier to a human-readable series name
    /// - Parameter identifier: The system model identifier (e.g., "MacBookPro18,3")
    /// - Returns: Human-readable model name (e.g., "MacBook Pro M1 Pro/Max")
    static func series(from identifier: String) -> String {
        // MacBook Pro models with Touch Bar
        if identifier.contains("MacBookPro13") { return "MacBook Pro 13\" (2016)" }
        if identifier.contains("MacBookPro14") { return "MacBook Pro (2017)" }
        if identifier.contains("MacBookPro15") { return "MacBook Pro (2018-19)" }
        if identifier.contains("MacBookPro16") { return "MacBook Pro (2019-20)" }
        if identifier.contains("MacBookPro17") { return "MacBook Pro M1" }
        if identifier.contains("MacBookPro18") { return "MacBook Pro M1 Pro/Max" }

        // MacBook Air models (some have virtual Touch Bar support)
        if identifier.contains("MacBookAir") { return "MacBook Air" }

        // Default fallback
        return "MacBook Pro"
    }

    /// Check if the model identifier indicates a Mac with Touch Bar
    /// - Parameter identifier: The system model identifier
    /// - Returns: True if the model has a Touch Bar
    static func hasTouchBar(identifier: String) -> Bool {
        // Touch Bar was introduced with MacBookPro13,1 (2016) and removed with M3 Pro/Max
        let touchBarModels = [
            "MacBookPro13", // 2016 (13" and 15")
            "MacBookPro14", // 2017
            "MacBookPro15", // 2018-2019
            "MacBookPro16", // 2019-2020 (16")
            "MacBookPro17", // M1 (13")
            "MacBookPro18", // M1 Pro/Max (14" and 16")
        ]

        return touchBarModels.contains { identifier.contains($0) }
    }
}
