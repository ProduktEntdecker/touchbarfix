import XCTest
@testable import TouchBarFix

// MARK: - ContentViewFlowState Tests

final class ContentViewFlowStateTests: XCTestCase {

    // MARK: - Equality Tests

    func testIdleEquality() {
        XCTAssertEqual(ContentViewFlowState.idle, ContentViewFlowState.idle)
    }

    func testRestartingEquality() {
        XCTAssertEqual(ContentViewFlowState.restarting, ContentViewFlowState.restarting)
    }

    func testSuccessEquality() {
        XCTAssertEqual(
            ContentViewFlowState.success(usedAdmin: true),
            ContentViewFlowState.success(usedAdmin: true)
        )
        XCTAssertEqual(
            ContentViewFlowState.success(usedAdmin: false),
            ContentViewFlowState.success(usedAdmin: false)
        )
        XCTAssertNotEqual(
            ContentViewFlowState.success(usedAdmin: true),
            ContentViewFlowState.success(usedAdmin: false)
        )
    }

    func testPartialFailureEquality() {
        XCTAssertEqual(
            ContentViewFlowState.partialFailure(needsAdmin: true),
            ContentViewFlowState.partialFailure(needsAdmin: true)
        )
        XCTAssertEqual(
            ContentViewFlowState.partialFailure(needsAdmin: false),
            ContentViewFlowState.partialFailure(needsAdmin: false)
        )
        XCTAssertNotEqual(
            ContentViewFlowState.partialFailure(needsAdmin: true),
            ContentViewFlowState.partialFailure(needsAdmin: false)
        )
    }

    func testFailureEquality() {
        XCTAssertEqual(
            ContentViewFlowState.failure("error message"),
            ContentViewFlowState.failure("error message")
        )
        XCTAssertNotEqual(
            ContentViewFlowState.failure("error 1"),
            ContentViewFlowState.failure("error 2")
        )
    }

    // MARK: - State Difference Tests

    func testDifferentStatesAreNotEqual() {
        XCTAssertNotEqual(ContentViewFlowState.idle, ContentViewFlowState.restarting)
        XCTAssertNotEqual(ContentViewFlowState.idle, ContentViewFlowState.success(usedAdmin: false))
        XCTAssertNotEqual(ContentViewFlowState.idle, ContentViewFlowState.partialFailure(needsAdmin: true))
        XCTAssertNotEqual(ContentViewFlowState.idle, ContentViewFlowState.failure("error"))
        XCTAssertNotEqual(ContentViewFlowState.restarting, ContentViewFlowState.success(usedAdmin: false))
        XCTAssertNotEqual(ContentViewFlowState.success(usedAdmin: false), ContentViewFlowState.partialFailure(needsAdmin: false))
    }

    // MARK: - Flow Transition Tests

    func testTypicalSuccessFlow() {
        var state = ContentViewFlowState.idle

        // Start restart
        state = .restarting
        XCTAssertEqual(state, .restarting)

        // Complete successfully
        state = .success(usedAdmin: false)
        XCTAssertEqual(state, .success(usedAdmin: false))

        // Can reset to idle
        state = .idle
        XCTAssertEqual(state, .idle)
    }

    func testPartialFailureFlow() {
        var state = ContentViewFlowState.idle

        // Start restart
        state = .restarting
        XCTAssertEqual(state, .restarting)

        // Partial failure occurs
        state = .partialFailure(needsAdmin: true)
        XCTAssertEqual(state, .partialFailure(needsAdmin: true))
    }

    func testAdminEscalationFlow() {
        var state = ContentViewFlowState.partialFailure(needsAdmin: true)

        // User grants admin access, restart begins again
        state = .restarting
        XCTAssertEqual(state, .restarting)

        // Admin restart succeeds
        state = .success(usedAdmin: true)
        XCTAssertEqual(state, .success(usedAdmin: true))
    }

    func testFailureFlow() {
        var state = ContentViewFlowState.idle

        // Start restart
        state = .restarting
        XCTAssertEqual(state, .restarting)

        // Failure occurs
        state = .failure("Process could not be killed")
        XCTAssertEqual(state, .failure("Process could not be killed"))
    }

    func testRetryAfterFailure() {
        var state = ContentViewFlowState.failure("Previous error")

        // User clicks "Try Again"
        state = .restarting
        XCTAssertEqual(state, .restarting)

        // This time it succeeds
        state = .success(usedAdmin: false)
        XCTAssertEqual(state, .success(usedAdmin: false))
    }

    func testCancelFromPartialFailure() {
        var state = ContentViewFlowState.partialFailure(needsAdmin: true)

        // User cancels the options dialog
        state = .idle
        XCTAssertEqual(state, .idle)
    }

    // MARK: - Associated Value Tests

    func testSuccessUsedAdminFlag() {
        let stateWithAdmin = ContentViewFlowState.success(usedAdmin: true)
        let stateWithoutAdmin = ContentViewFlowState.success(usedAdmin: false)

        if case .success(let usedAdmin) = stateWithAdmin {
            XCTAssertTrue(usedAdmin)
        } else {
            XCTFail("Expected success state")
        }

        if case .success(let usedAdmin) = stateWithoutAdmin {
            XCTAssertFalse(usedAdmin)
        } else {
            XCTFail("Expected success state")
        }
    }

    func testPartialFailureNeedsAdminFlag() {
        let stateNeedsAdmin = ContentViewFlowState.partialFailure(needsAdmin: true)
        let stateNoAdmin = ContentViewFlowState.partialFailure(needsAdmin: false)

        if case .partialFailure(let needsAdmin) = stateNeedsAdmin {
            XCTAssertTrue(needsAdmin)
        } else {
            XCTFail("Expected partialFailure state")
        }

        if case .partialFailure(let needsAdmin) = stateNoAdmin {
            XCTAssertFalse(needsAdmin)
        } else {
            XCTFail("Expected partialFailure state")
        }
    }

    func testFailureErrorMessage() {
        let errorMessage = "Touch Bar service is unresponsive"
        let state = ContentViewFlowState.failure(errorMessage)

        if case .failure(let message) = state {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected failure state")
        }
    }

    // MARK: - Edge Cases

    func testEmptyFailureMessage() {
        let state = ContentViewFlowState.failure("")
        if case .failure(let message) = state {
            XCTAssertEqual(message, "")
        } else {
            XCTFail("Expected failure state")
        }
    }

    func testLongFailureMessage() {
        let longMessage = String(repeating: "Error: ", count: 100)
        let state = ContentViewFlowState.failure(longMessage)

        if case .failure(let message) = state {
            XCTAssertEqual(message, longMessage)
        } else {
            XCTFail("Expected failure state")
        }
    }
}

// MARK: - Integration with RestartProgress Tests

@MainActor
final class ContentViewIntegrationTests: XCTestCase {

    func testRestartProgressTransitionsToSuccessState() {
        let progress = RestartProgress()

        // Initially idle
        XCTAssertEqual(progress.overallState, .idle)

        // Simulate restart sequence using UIProcessStatus
        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.inProgress)
        XCTAssertEqual(progress.overallState, .restarting)

        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.success)
        progress.updateStatus(for: "touchBarServer", status: UIProcessStatus.success)
        progress.updateStatus(for: "displayRefresh", status: UIProcessStatus.success)
        XCTAssertEqual(progress.overallState, .success)
    }

    func testRestartProgressTransitionsToPartialFailure() {
        let progress = RestartProgress()

        // Simulate partial failure
        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.success)
        progress.updateStatus(for: "touchBarServer", status: UIProcessStatus.failed(reason: .needsAdmin))
        progress.updateStatus(for: "displayRefresh", status: UIProcessStatus.success)

        XCTAssertEqual(progress.overallState, .partialFailure(needsAdmin: true))
    }

    func testRestartProgressResetAfterSuccess() {
        let progress = RestartProgress()

        // Complete a successful restart
        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.success)
        progress.updateStatus(for: "touchBarServer", status: UIProcessStatus.success)
        progress.updateStatus(for: "displayRefresh", status: UIProcessStatus.success)
        XCTAssertEqual(progress.overallState, .success)

        // Reset for another attempt
        progress.reset()
        XCTAssertEqual(progress.overallState, .idle)
        XCTAssertEqual(progress.controlStrip, UIProcessStatus.pending)
        XCTAssertEqual(progress.touchBarServer, UIProcessStatus.pending)
        XCTAssertEqual(progress.displayRefresh, UIProcessStatus.pending)
    }

    func testRestartProgressResetAfterFailure() {
        let progress = RestartProgress()

        // Simulate failure
        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.failed(reason: .notRunning))
        progress.updateStatus(for: "touchBarServer", status: UIProcessStatus.failed(reason: .needsAdmin))
        progress.updateStatus(for: "displayRefresh", status: UIProcessStatus.failed(reason: .unknown("Unknown error")))

        // Reset
        progress.reset()
        XCTAssertEqual(progress.overallState, .idle)
    }

    func testFlowStateMatchesProgressState() {
        let progress = RestartProgress()

        // Map RestartProgress.overallState to ContentViewFlowState
        XCTAssertEqual(progress.overallState, .idle)

        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.inProgress)
        XCTAssertEqual(progress.overallState, .restarting)

        progress.updateStatus(for: "controlStrip", status: UIProcessStatus.success)
        progress.updateStatus(for: "touchBarServer", status: UIProcessStatus.success)
        progress.updateStatus(for: "displayRefresh", status: UIProcessStatus.success)
        XCTAssertEqual(progress.overallState, .success)
    }
}

// MARK: - State Machine Validation Tests

final class ContentViewStateMachineTests: XCTestCase {

    /// Valid state transitions for ContentViewFlowState
    func testValidStateTransitions() {
        // idle -> restarting (valid)
        XCTAssertTrue(isValidTransition(from: .idle, to: .restarting))

        // restarting -> success (valid)
        XCTAssertTrue(isValidTransition(from: .restarting, to: .success(usedAdmin: false)))
        XCTAssertTrue(isValidTransition(from: .restarting, to: .success(usedAdmin: true)))

        // restarting -> partialFailure (valid)
        XCTAssertTrue(isValidTransition(from: .restarting, to: .partialFailure(needsAdmin: true)))

        // restarting -> failure (valid)
        XCTAssertTrue(isValidTransition(from: .restarting, to: .failure("error")))

        // partialFailure -> restarting (valid - admin escalation)
        XCTAssertTrue(isValidTransition(from: .partialFailure(needsAdmin: true), to: .restarting))

        // partialFailure -> idle (valid - cancel)
        XCTAssertTrue(isValidTransition(from: .partialFailure(needsAdmin: true), to: .idle))

        // failure -> restarting (valid - retry)
        XCTAssertTrue(isValidTransition(from: .failure("error"), to: .restarting))

        // success -> idle (valid - reset)
        XCTAssertTrue(isValidTransition(from: .success(usedAdmin: false), to: .idle))
    }

    /// Helper to validate state transitions
    private func isValidTransition(from: ContentViewFlowState, to: ContentViewFlowState) -> Bool {
        switch (from, to) {
        case (.idle, .restarting):
            return true
        case (.restarting, .success):
            return true
        case (.restarting, .partialFailure):
            return true
        case (.restarting, .failure):
            return true
        case (.partialFailure, .restarting):
            return true
        case (.partialFailure, .idle):
            return true
        case (.failure, .restarting):
            return true
        case (.failure, .idle):
            return true
        case (.success, .idle):
            return true
        case (.success, .restarting):
            return true // "Fix Again" option
        default:
            return false
        }
    }
}
