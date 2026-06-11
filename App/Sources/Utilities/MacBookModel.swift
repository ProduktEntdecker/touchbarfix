import Foundation

/// Centralized MacBook model identification utility
/// Converts model identifiers (e.g., "MacBookPro17,1") to human-readable names
/// and is the single source of truth for which models have a Touch Bar.
struct MacBookModel {

    /// Exact model identifiers of every Mac that shipped with a Touch Bar.
    /// The Touch Bar was introduced with the 2016 MacBook Pro and last shipped
    /// in the 13" M2 MacBook Pro (2022, Mac14,7). The October 2021 14"/16"
    /// redesign (MacBookPro18,x) removed the Touch Bar. The base 13" models
    /// MacBookPro13,1 and MacBookPro14,1 have physical function keys instead.
    static let touchBarModelIdentifiers: Set<String> = [
        "MacBookPro13,2", "MacBookPro13,3",                    // 2016 (13" / 15")
        "MacBookPro14,2", "MacBookPro14,3",                    // 2017 (13" / 15")
        "MacBookPro15,1", "MacBookPro15,2",                    // 2018-2019 (15" / 13")
        "MacBookPro15,3", "MacBookPro15,4",                    // 2019 (15" / 13")
        "MacBookPro16,1", "MacBookPro16,2",                    // 2019-2020 (16" / 13")
        "MacBookPro16,3", "MacBookPro16,4",                    // 2020 (13") / 2019 (16")
        "MacBookPro17,1",                                      // 2020 (13" M1)
        "Mac14,7"                                              // 2022 (13" M2) - last Touch Bar Mac
    ]

    /// Convert a model identifier to a human-readable series name
    /// - Parameter identifier: The system model identifier (e.g., "MacBookPro17,1")
    /// - Returns: Human-readable model name (e.g., "MacBook Pro M1")
    static func series(from identifier: String) -> String {
        // MacBook Pro models
        if identifier.contains("MacBookPro13") { return "MacBook Pro 13\" (2016)" }
        if identifier.contains("MacBookPro14") { return "MacBook Pro (2017)" }
        if identifier.contains("MacBookPro15") { return "MacBook Pro (2018-19)" }
        if identifier.contains("MacBookPro16") { return "MacBook Pro (2019-20)" }
        if identifier.contains("MacBookPro17") { return "MacBook Pro M1" }
        if identifier.contains("MacBookPro18") { return "MacBook Pro M1 Pro/Max" }
        if identifier.contains("Mac14,7") { return "MacBook Pro 13\" M2" }

        // MacBook Air models (some have virtual Touch Bar support)
        if identifier.contains("MacBookAir") { return "MacBook Air" }

        // Default fallback
        return "MacBook Pro"
    }

    /// Check if the model identifier indicates a Mac with Touch Bar
    /// - Parameter identifier: The system model identifier
    /// - Returns: True if the model has a Touch Bar
    static func hasTouchBar(identifier: String) -> Bool {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)

        // Exact match, with tolerance for suffixed variants (e.g., "MacBookPro17,1-...")
        return touchBarModelIdentifiers.contains(trimmed)
            || touchBarModelIdentifiers.contains { trimmed.hasPrefix($0 + "-") }
    }
}
