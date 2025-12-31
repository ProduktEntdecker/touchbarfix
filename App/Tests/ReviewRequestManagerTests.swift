import XCTest
@testable import TouchBarFix

final class ReviewRequestManagerTests: XCTestCase {

    var testUserDefaults: TestUserDefaults!

    override func setUp() {
        super.setUp()
        testUserDefaults = TestUserDefaults()
    }

    override func tearDown() {
        testUserDefaults = nil
        super.tearDown()
    }

    // MARK: - shouldRequestReview Tests

    func test_shouldRequestReview_onFirstFix_returnsFalse() {
        let sut = createSUT()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 1),
            "Should not request review on first fix")
    }

    func test_shouldRequestReview_atSecondFix_returnsTrue() {
        let sut = createSUT()

        XCTAssertTrue(sut.shouldRequestReview(afterSuccessfulFix: 2),
            "Should request review at second fix")
    }

    func test_shouldRequestReview_atFifthFix_returnsTrue() {
        let sut = createSUT()

        XCTAssertTrue(sut.shouldRequestReview(afterSuccessfulFix: 5),
            "Should request review at fifth fix")
    }

    func test_shouldRequestReview_atTenthFix_returnsTrue() {
        let sut = createSUT()

        XCTAssertTrue(sut.shouldRequestReview(afterSuccessfulFix: 10),
            "Should request review at tenth fix")
    }

    func test_shouldRequestReview_atNonTriggerCount_returnsFalse() {
        let sut = createSUT()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 3))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 4))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 6))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 7))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 8))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 9))
    }

    func test_shouldRequestReview_afterReviewCompleted_returnsFalse() {
        let sut = createSUT()
        sut.markReviewCompleted()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 2),
            "Should not request review if already reviewed")
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 5))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 10))
    }

    func test_shouldRequestReview_afterUserDeclined_returnsFalse() {
        let sut = createSUT()
        sut.markReviewDeclined()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 2),
            "Should not request review if user declined")
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 5))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 10))
    }

    func test_shouldRequestReview_afterTwoPrompts_returnsFalse() {
        let sut = createSUT()
        sut.recordReviewRequest() // First prompt
        sut.recordReviewRequest() // Second prompt

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 10),
            "Should not prompt more than twice")
    }

    func test_shouldRequestReview_withinCooldownPeriod_returnsFalse() {
        let sut = createSUT()
        sut.recordReviewRequest() // Records current date

        // Immediately check again - should be within 30 day cooldown
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 5),
            "Should not prompt within cooldown period")
    }

    // MARK: - shouldShowReviewButton Tests

    func test_shouldShowReviewButton_initially_returnsTrue() {
        let sut = createSUT()

        XCTAssertTrue(sut.shouldShowReviewButton(),
            "Should show review button initially")
    }

    func test_shouldShowReviewButton_afterDeclined_returnsFalse() {
        let sut = createSUT()
        sut.markReviewDeclined()

        XCTAssertFalse(sut.shouldShowReviewButton(),
            "Should not show button after user declined")
    }

    func test_shouldShowReviewButton_afterReviewCompleted_returnsFalse() {
        let sut = createSUT()
        sut.markReviewCompleted()

        XCTAssertFalse(sut.shouldShowReviewButton(),
            "Should not show button after review completed")
    }

    // MARK: - getReviewRequestMessage Tests

    func test_getReviewRequestMessage_atSecondFix_returnsAppropriateMessage() {
        let sut = createSUT()
        let message = sut.getReviewRequestMessage(fixCount: 2)

        XCTAssertTrue(message.contains("twice"),
            "Second fix message should mention 'twice'")
        XCTAssertTrue(message.contains("review"),
            "Message should mention review")
    }

    func test_getReviewRequestMessage_atFifthFix_mentionsPowerUser() {
        let sut = createSUT()
        let message = sut.getReviewRequestMessage(fixCount: 5)

        XCTAssertTrue(message.contains("power user") || message.contains("5"),
            "Fifth fix message should mention power user or count")
    }

    func test_getReviewRequestMessage_atTenthFix_mentionsIncredible() {
        let sut = createSUT()
        let message = sut.getReviewRequestMessage(fixCount: 10)

        XCTAssertTrue(message.contains("Incredible") || message.contains("10"),
            "Tenth fix message should be celebratory")
    }

    func test_getReviewRequestMessage_atOtherCounts_returnsDefaultMessage() {
        let sut = createSUT()
        let message = sut.getReviewRequestMessage(fixCount: 3)

        XCTAssertTrue(message.contains("Loving") || message.contains("review"),
            "Default message should be positive and mention review")
    }

    // MARK: - getOptimalReviewTiming Tests

    func test_getOptimalReviewTiming_returns3Seconds() {
        let sut = createSUT()

        XCTAssertEqual(sut.getOptimalReviewTiming(), 3.0,
            "Optimal timing should be 3 seconds")
    }

    // MARK: - State Persistence Tests

    func test_markReviewCompleted_persistsState() {
        let sut1 = createSUT()
        sut1.markReviewCompleted()

        // Create new instance with same UserDefaults
        let sut2 = createSUT()

        XCTAssertTrue(sut2.reviewRequested,
            "Review completed state should persist")
    }

    func test_markReviewDeclined_persistsState() {
        let sut1 = createSUT()
        sut1.markReviewDeclined()

        let sut2 = createSUT()

        XCTAssertTrue(sut2.userDeclined,
            "Review declined state should persist")
    }

    func test_recordReviewRequest_incrementsPromptCount() {
        let sut = createSUT()
        XCTAssertEqual(sut.promptCount, 0)

        sut.recordReviewRequest()
        XCTAssertEqual(sut.promptCount, 1)

        sut.recordReviewRequest()
        XCTAssertEqual(sut.promptCount, 2)
    }

    func test_promptCount_persistsAcrossInstances() {
        let sut1 = createSUT()
        sut1.recordReviewRequest()
        sut1.recordReviewRequest()

        let sut2 = createSUT()

        XCTAssertEqual(sut2.promptCount, 2,
            "Prompt count should persist across instances")
    }

    // MARK: - supportsNativeReviewPrompt Tests

    func test_supportsNativeReviewPrompt_onMacOS12Plus_returnsTrue() {
        let sut = createSUT()

        // We're testing on macOS 13+, so this should be true
        if #available(macOS 12.0, *) {
            XCTAssertTrue(sut.supportsNativeReviewPrompt)
        }
    }

    // MARK: - Edge Cases

    func test_shouldRequestReview_withZeroFixes_returnsFalse() {
        let sut = createSUT()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 0),
            "Should not request review with zero fixes")
    }

    func test_shouldRequestReview_withNegativeFixes_returnsFalse() {
        let sut = createSUT()

        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: -1),
            "Should not request review with negative fixes")
    }

    func test_shouldRequestReview_withVeryHighFixCount_returnsFalse() {
        let sut = createSUT()

        // After 10, no more trigger points
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 11))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 100))
        XCTAssertFalse(sut.shouldRequestReview(afterSuccessfulFix: 1000))
    }

    // MARK: - Helper Methods

    private func createSUT() -> ReviewRequestManager {
        return ReviewRequestManager(userDefaults: testUserDefaults.userDefaults)
    }
}
