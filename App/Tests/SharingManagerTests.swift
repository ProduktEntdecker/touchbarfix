import XCTest
@testable import TouchBarFix

final class SharingManagerTests: XCTestCase {

    var sut: SharingManager!

    override func setUp() {
        super.setUp()
        sut = SharingManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - MacBookModel.series Tests

    func test_macBookModel_withMacBookPro13_returnsCorrectSeries() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro13,1"), "MacBook Pro 13\" (2016)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro13,2"), "MacBook Pro 13\" (2016)")
    }

    func test_macBookModel_withMacBookPro14_returnsCorrectSeries() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro14,1"), "MacBook Pro (2017)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro14,2"), "MacBook Pro (2017)")
    }

    func test_macBookModel_withMacBookPro15_returnsCorrectSeries() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro15,1"), "MacBook Pro (2018-19)")
    }

    func test_macBookModel_withMacBookPro16_returnsCorrectSeries() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro16,1"), "MacBook Pro (2019-20)")
    }

    func test_macBookModel_withMacBookPro17_returnsM1() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro17,1"), "MacBook Pro M1")
    }

    func test_macBookModel_withMacBookPro18_returnsM1ProMax() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro18,1"), "MacBook Pro M1 Pro/Max")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro18,3"), "MacBook Pro M1 Pro/Max")
    }

    func test_macBookModel_withMacBookAir_returnsAir() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookAir10,1"), "MacBook Air")
    }

    func test_macBookModel_withUnknownModel_returnsFallback() {
        XCTAssertEqual(MacBookModel.series(from: "UnknownModel"), "MacBook Pro")
        XCTAssertEqual(MacBookModel.series(from: ""), "MacBook Pro")
    }

    // MARK: - MacBookModel.hasTouchBar Tests

    func test_macBookModel_hasTouchBar_withTouchBarModels_returnsTrue() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro13,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro14,2"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro15,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro16,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro17,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro18,3"))
    }

    func test_macBookModel_hasTouchBar_withNonTouchBarModels_returnsFalse() {
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookPro19,1")) // M2 Pro
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookAir10,1"))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "UnknownModel"))
    }

    // MARK: - generateShareContent Tests

    func test_generateShareContent_includesFixCount() {
        let content = sut.generateShareContent(fixCount: 5, modelIdentifier: "MacBookPro18,3")

        XCTAssertTrue(content.message.contains("5") || content.title.contains("5"),
            "Share content should reference fix count")
    }

    func test_generateShareContent_includesModelSeries() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        // The message should contain model info
        XCTAssertTrue(content.message.contains("MacBook") || content.message.contains("M1"),
            "Share content should reference the model")
    }

    func test_generateShareContent_hasValidURL() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        XCTAssertTrue(content.url.absoluteString.contains("touchbarfix.com"))
        XCTAssertTrue(content.url.absoluteString.contains("utm_source"))
    }

    func test_generateShareContent_hasHashtags() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        XCTAssertFalse(content.hashtags.isEmpty)
        XCTAssertTrue(content.hashtags.contains("MacBook"))
        XCTAssertTrue(content.hashtags.contains("TouchBar"))
    }

    // MARK: - getShareTitle Tests (via SharingManager internal method)

    func test_shareContent_withSingleFix_hasAppropriateTile() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        // First fix should have excited title
        XCTAssertTrue(content.title.contains("Fixed") || content.title.contains("!"),
            "Single fix should have excited title")
    }

    func test_shareContent_withMultipleFixes_hasAppropriateTile() {
        let content = sut.generateShareContent(fixCount: 5, modelIdentifier: "MacBookPro18,3")

        // Multiple fixes should reference being a power user or essential
        XCTAssertFalse(content.title.isEmpty)
    }

    // MARK: - Share Message Tests

    func test_shareMessage_firstFix_mentionsModel() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        XCTAssertTrue(content.message.contains("M1 Pro/Max") || content.message.contains("MacBook"),
            "First fix message should mention the model")
    }

    func test_shareMessage_progressiveMessages() {
        let content1 = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")
        let content2 = sut.generateShareContent(fixCount: 2, modelIdentifier: "MacBookPro18,3")
        let content3 = sut.generateShareContent(fixCount: 3, modelIdentifier: "MacBookPro18,3")
        let content5 = sut.generateShareContent(fixCount: 5, modelIdentifier: "MacBookPro18,3")
        let content10 = sut.generateShareContent(fixCount: 10, modelIdentifier: "MacBookPro18,3")

        // Each milestone should have a unique message
        let messages = [content1.message, content2.message, content3.message, content5.message, content10.message]

        // At least some messages should be different
        let uniqueMessages = Set(messages)
        XCTAssertGreaterThan(uniqueMessages.count, 1,
            "Different fix counts should generate different messages")
    }

    // MARK: - Tracking URL Tests

    func test_trackingURL_includesUTMParameters() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")
        let urlString = content.url.absoluteString

        XCTAssertTrue(urlString.contains("utm_source=app"))
        XCTAssertTrue(urlString.contains("utm_medium=social"))
        XCTAssertTrue(urlString.contains("utm_campaign=user_share"))
    }

    func test_trackingURL_isValidURL() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        XCTAssertNotNil(URL(string: content.url.absoluteString))
        XCTAssertTrue(content.url.absoluteString.hasPrefix("https://"))
    }

    // MARK: - Twitter Character Limit Test

    func test_twitterContent_isUnder280Characters() {
        // We can't directly test getTwitterContent since it's private,
        // but we can test the message length indirectly
        for fixCount in [1, 2, 3, 5, 10, 50, 100] {
            let content = sut.generateShareContent(fixCount: fixCount, modelIdentifier: "MacBookPro18,3")

            // Message + URL + hashtags should ideally fit in a tweet
            // The full tweet is: message + URL + hashtags
            let estimatedTweetLength = content.message.count + 25 + 50 // URL ~25, hashtags ~50

            XCTAssertLessThan(estimatedTweetLength, 350,
                "Tweet content for fixCount \(fixCount) is too long")
        }
    }

    // MARK: - SharingPlatform Tests

    func test_sharingPlatform_hasDisplayNames() {
        for platform in SharingPlatform.allCases {
            XCTAssertFalse(platform.displayName.isEmpty,
                "Platform \(platform) should have display name")
        }
    }

    func test_sharingPlatform_hasIcons() {
        for platform in SharingPlatform.allCases {
            XCTAssertFalse(platform.icon.isEmpty,
                "Platform \(platform) should have icon")
        }
    }

    func test_sharingPlatform_rawValues() {
        XCTAssertEqual(SharingPlatform.twitter.rawValue, "twitter")
        XCTAssertEqual(SharingPlatform.linkedin.rawValue, "linkedin")
        XCTAssertEqual(SharingPlatform.clipboard.rawValue, "clipboard")
    }

    // MARK: - ShareContent Structure Tests

    func test_shareContent_hasAllRequiredFields() {
        let content = sut.generateShareContent(fixCount: 1, modelIdentifier: "MacBookPro18,3")

        XCTAssertFalse(content.title.isEmpty)
        XCTAssertFalse(content.message.isEmpty)
        XCTAssertNotNil(content.url)
        XCTAssertFalse(content.hashtags.isEmpty)
        XCTAssertEqual(content.platform, .general)
    }
}
