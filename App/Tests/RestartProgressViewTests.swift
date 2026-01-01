import XCTest
@testable import TouchBarFix

@MainActor
final class RestartProgressViewTests: XCTestCase {
    var progress: RestartProgress!
    
    override func setUp() async throws {
        try await super.setUp()
        progress = RestartProgress()
    }
    
    override func tearDown() async throws {
        progress = nil
        try await super.tearDown()
    }
    
    // MARK: - UIProcessStatus Tests

    func testUIProcessStatusEquality() {
        XCTAssertEqual(UIProcessStatus.pending, UIProcessStatus.pending)
        XCTAssertEqual(UIProcessStatus.inProgress, UIProcessStatus.inProgress)
        XCTAssertEqual(UIProcessStatus.success, UIProcessStatus.success)
        XCTAssertEqual(
            UIProcessStatus.failed(reason: .needsAdmin),
            UIProcessStatus.failed(reason: .needsAdmin)
        )
        XCTAssertNotEqual(UIProcessStatus.pending, UIProcessStatus.inProgress)
        XCTAssertNotEqual(
            UIProcessStatus.failed(reason: .needsAdmin),
            UIProcessStatus.failed(reason: .notRunning)
        )
    }
    
    // MARK: - FailureReason Tests
    
    func testFailureReasonDescription() {
        XCTAssertEqual(FailureReason.needsAdmin.description, "Administrator privileges required")
        XCTAssertEqual(FailureReason.notRunning.description, "Process was not running")
        XCTAssertEqual(FailureReason.unknown("Custom error").description, "Custom error")
    }
    
    func testFailureReasonEquality() {
        XCTAssertEqual(FailureReason.needsAdmin, FailureReason.needsAdmin)
        XCTAssertEqual(FailureReason.notRunning, FailureReason.notRunning)
        XCTAssertEqual(FailureReason.unknown("test"), FailureReason.unknown("test"))
        XCTAssertNotEqual(FailureReason.needsAdmin, FailureReason.notRunning)
        XCTAssertNotEqual(FailureReason.unknown("a"), FailureReason.unknown("b"))
    }
    
    // MARK: - OverallRestartState Tests
    
    func testOverallRestartStateEquality() {
        XCTAssertEqual(OverallRestartState.idle, OverallRestartState.idle)
        XCTAssertEqual(OverallRestartState.restarting, OverallRestartState.restarting)
        XCTAssertEqual(OverallRestartState.success, OverallRestartState.success)
        XCTAssertEqual(
            OverallRestartState.partialFailure(needsAdmin: true),
            OverallRestartState.partialFailure(needsAdmin: true)
        )
        XCTAssertEqual(
            OverallRestartState.failure("error"),
            OverallRestartState.failure("error")
        )
        XCTAssertNotEqual(OverallRestartState.idle, OverallRestartState.restarting)
        XCTAssertNotEqual(
            OverallRestartState.partialFailure(needsAdmin: true),
            OverallRestartState.partialFailure(needsAdmin: false)
        )
    }
    
    // MARK: - UIProcessInfo Tests

    func testUIProcessInfoInitialization() {
        let process = UIProcessInfo(id: "test", displayName: "Test Process")
        XCTAssertEqual(process.id, "test")
        XCTAssertEqual(process.displayName, "Test Process")
        XCTAssertEqual(process.status, .pending)
    }

    func testUIProcessInfoWithCustomStatus() {
        let process = UIProcessInfo(id: "test", displayName: "Test", status: .success)
        XCTAssertEqual(process.status, .success)
    }
    
    // MARK: - RestartProgress Tests
    
    func testRestartProgressInitialState() {
        XCTAssertEqual(progress.controlStrip, .pending)
        XCTAssertEqual(progress.touchBarServer, .pending)
        XCTAssertEqual(progress.displayRefresh, .pending)
        XCTAssertEqual(progress.overallState, .idle)
    }
    
    func testRestartProgressProcessesList() {
        let processes = progress.processes
        XCTAssertEqual(processes.count, 3)
        XCTAssertEqual(processes[0].id, "controlStrip")
        XCTAssertEqual(processes[0].displayName, "Control Strip")
        XCTAssertEqual(processes[1].id, "touchBarServer")
        XCTAssertEqual(processes[1].displayName, "Touch Bar Server")
        XCTAssertEqual(processes[2].id, "displayRefresh")
        XCTAssertEqual(processes[2].displayName, "Display Refresh")
    }
    
    func testRestartProgressReset() {
        progress.controlStrip = .success
        progress.touchBarServer = .inProgress
        progress.displayRefresh = .failed(reason: .needsAdmin)
        progress.overallState = .partialFailure(needsAdmin: true)
        
        progress.reset()
        
        XCTAssertEqual(progress.controlStrip, .pending)
        XCTAssertEqual(progress.touchBarServer, .pending)
        XCTAssertEqual(progress.displayRefresh, .pending)
        XCTAssertEqual(progress.overallState, .idle)
    }
    
    func testUpdateStatusControlStrip() {
        progress.updateStatus(for: "controlStrip", status: .success)
        XCTAssertEqual(progress.controlStrip, .success)
    }
    
    func testUpdateStatusTouchBarServer() {
        progress.updateStatus(for: "touchBarServer", status: .inProgress)
        XCTAssertEqual(progress.touchBarServer, .inProgress)
    }
    
    func testUpdateStatusDisplayRefresh() {
        progress.updateStatus(for: "displayRefresh", status: .failed(reason: .notRunning))
        XCTAssertEqual(progress.displayRefresh, .failed(reason: .notRunning))
    }
    
    func testUpdateStatusUnknownProcess() {
        let originalControlStrip = progress.controlStrip
        let originalTouchBarServer = progress.touchBarServer
        let originalDisplayRefresh = progress.displayRefresh
        
        progress.updateStatus(for: "unknownProcess", status: .success)
        
        XCTAssertEqual(progress.controlStrip, originalControlStrip)
        XCTAssertEqual(progress.touchBarServer, originalTouchBarServer)
        XCTAssertEqual(progress.displayRefresh, originalDisplayRefresh)
    }
    
    // MARK: - Overall State Calculation Tests
    
    func testOverallStateIdleWhenAllPending() {
        XCTAssertEqual(progress.overallState, .idle)
    }
    
    func testOverallStateRestartingWhenAnyInProgress() {
        progress.updateStatus(for: "controlStrip", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
        
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
    }
    
    func testOverallStateSuccessWhenAllSucceed() {
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .success)
        progress.updateStatus(for: "displayRefresh", status: .success)
        XCTAssertEqual(progress.overallState, .success)
    }
    
    func testOverallStatePartialFailureWhenMixedResults() {
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .failed(reason: .needsAdmin))
        progress.updateStatus(for: "displayRefresh", status: .success)
        XCTAssertEqual(progress.overallState, .partialFailure(needsAdmin: true))
    }
    
    func testOverallStatePartialFailureWithoutAdmin() {
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .failed(reason: .notRunning))
        progress.updateStatus(for: "displayRefresh", status: .success)
        XCTAssertEqual(progress.overallState, .partialFailure(needsAdmin: false))
    }
    
    func testOverallStateFailureWhenAllFail() {
        progress.updateStatus(for: "controlStrip", status: .failed(reason: .needsAdmin))
        progress.updateStatus(for: "touchBarServer", status: .failed(reason: .notRunning))
        progress.updateStatus(for: "displayRefresh", status: .failed(reason: .unknown("Test")))
        
        if case .failure(let message) = progress.overallState {
            XCTAssertTrue(message.contains("Administrator privileges required"))
            XCTAssertTrue(message.contains("Process was not running"))
            XCTAssertTrue(message.contains("Test"))
        } else {
            XCTFail("Expected failure state")
        }
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransitionFromIdleToRestarting() {
        XCTAssertEqual(progress.overallState, .idle)
        progress.updateStatus(for: "controlStrip", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
    }
    
    func testStateTransitionFromRestartingToSuccess() {
        progress.updateStatus(for: "controlStrip", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
        
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .success)
        progress.updateStatus(for: "displayRefresh", status: .success)
        XCTAssertEqual(progress.overallState, .success)
    }
    
    func testCompleteWorkflow() {
        // Start
        XCTAssertEqual(progress.overallState, .idle)
        
        // First process starts
        progress.updateStatus(for: "controlStrip", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
        
        // First process completes, second starts
        progress.updateStatus(for: "controlStrip", status: .success)
        progress.updateStatus(for: "touchBarServer", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
        
        // Second completes, third starts
        progress.updateStatus(for: "touchBarServer", status: .success)
        progress.updateStatus(for: "displayRefresh", status: .inProgress)
        XCTAssertEqual(progress.overallState, .restarting)
        
        // All complete
        progress.updateStatus(for: "displayRefresh", status: .success)
        XCTAssertEqual(progress.overallState, .success)
    }
}
