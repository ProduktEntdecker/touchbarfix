import XCTest
@testable import TouchBarFix

final class MacBookModelTests: XCTestCase {

    // MARK: - series(from:) Tests

    func testSeries2016MacBookPro13() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro13,2"), "MacBook Pro 13\" (2016)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro13,3"), "MacBook Pro 13\" (2016)")
    }

    func testSeries2017MacBookPro() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro14,2"), "MacBook Pro (2017)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro14,3"), "MacBook Pro (2017)")
    }

    func testSeries2018_2019MacBookPro() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro15,1"), "MacBook Pro (2018-19)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro15,2"), "MacBook Pro (2018-19)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro15,3"), "MacBook Pro (2018-19)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro15,4"), "MacBook Pro (2018-19)")
    }

    func testSeries2019_2020MacBookPro() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro16,1"), "MacBook Pro (2019-20)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro16,2"), "MacBook Pro (2019-20)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro16,3"), "MacBook Pro (2019-20)")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro16,4"), "MacBook Pro (2019-20)")
    }

    func testSeriesM1MacBookPro() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro17,1"), "MacBook Pro M1")
    }

    func testSeriesM1ProMaxMacBookPro() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro18,3"), "MacBook Pro M1 Pro/Max")
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro18,4"), "MacBook Pro M1 Pro/Max")
    }

    func testSeriesMacBookAir() {
        XCTAssertEqual(MacBookModel.series(from: "MacBookAir9,1"), "MacBook Air")
        XCTAssertEqual(MacBookModel.series(from: "MacBookAir10,1"), "MacBook Air")
    }

    func testSeriesDefaultFallback() {
        // Unknown model identifiers should return default "MacBook Pro"
        XCTAssertEqual(MacBookModel.series(from: "Unknown"), "MacBook Pro")
        XCTAssertEqual(MacBookModel.series(from: ""), "MacBook Pro")
        XCTAssertEqual(MacBookModel.series(from: "iMac21,1"), "MacBook Pro")
    }

    // MARK: - hasTouchBar(identifier:) Tests

    func testHasTouchBar2016Models() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro13,2"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro13,3"))
    }

    func testHasTouchBar2017Models() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro14,2"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro14,3"))
    }

    func testHasTouchBar2018_2019Models() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro15,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro15,2"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro15,3"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro15,4"))
    }

    func testHasTouchBar2019_2020Models() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro16,1"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro16,2"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro16,3"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro16,4"))
    }

    func testHasTouchBarM1Model() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro17,1"))
    }

    func testHasTouchBarM1ProMaxModels() {
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro18,3"))
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro18,4"))
    }

    func testNoTouchBarMacBookAir() {
        // MacBook Air never had Touch Bar
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookAir9,1"))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookAir10,1"))
    }

    func testNoTouchBarM2Models() {
        // M2 and later removed Touch Bar
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookPro19,1"))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacBookPro20,1"))
    }

    func testNoTouchBarOtherMacs() {
        // Desktop Macs and other models
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "iMac21,1"))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacMini9,1"))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "MacPro7,1"))
    }

    func testNoTouchBarEmptyOrUnknown() {
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: ""))
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "Unknown"))
    }

    // MARK: - Edge Cases

    func testModelIdentifierWithWhitespace() {
        // Test that identifiers with extra characters are still matched
        XCTAssertTrue(MacBookModel.hasTouchBar(identifier: "MacBookPro18,3-custom"))
        XCTAssertEqual(MacBookModel.series(from: "MacBookPro18,3-custom"), "MacBook Pro M1 Pro/Max")
    }

    func testCaseSensitivity() {
        // The current implementation is case-sensitive
        XCTAssertFalse(MacBookModel.hasTouchBar(identifier: "macbookpro18,3"))
        XCTAssertEqual(MacBookModel.series(from: "macbookpro18,3"), "MacBook Pro")
    }
}
