import XCTest
@testable import TouchBarRestarter

final class TouchBarManagerTests: XCTestCase {
    var touchBarManager: TouchBarManager!
    
    override func setUp() {
        super.setUp()
        touchBarManager = TouchBarManager()
    }
    
    override func tearDown() {
        touchBarManager = nil
        super.tearDown()
    }
    
    func testTouchBarDetection() {
        // Test that hasTouchBar property is set
        XCTAssertNotNil(touchBarManager.hasTouchBar)
        
        // This will vary depending on the test machine
        // You might want to mock this in a real test environment
        print("Touch Bar detected: \(touchBarManager.hasTouchBar)")
    }
    
    func testGetTouchBarStatus() {
        let status = touchBarManager.getTouchBarStatus()
        
        // Status should be one of the expected values
        let validStatuses = ["Running", "Not Running", "Unknown", "No Touch Bar"]
        XCTAssertTrue(validStatuses.contains(status), "Status '\(status)' is not valid")
    }
    
    func testRestartCountPersistence() {
        // Get initial count
        let initialCount = touchBarManager.restartCount
        
        // Create new instance to test persistence
        let newManager = TouchBarManager()
        XCTAssertEqual(newManager.restartCount, initialCount, "Restart count should persist")
    }
    
    func testProcessCheck() {
        // Test checking if a known process is running (Finder should be running on macOS)
        let isRunning = touchBarManager.checkIfProcessRunning("Finder")
        XCTAssertTrue(isRunning, "Finder should always be running on macOS")
        
        // Test checking a non-existent process
        let notRunning = touchBarManager.checkIfProcessRunning("ThisProcessDoesNotExist123456")
        XCTAssertFalse(notRunning, "Non-existent process should not be running")
    }
    
    func testErrorEnumDescription() {
        let errors: [TouchBarError] = [
            .noTouchBar,
            .processNotFound,
            .killFailed("TestProcess"),
            .serviceRestartFailed,
            .unknown("Test error")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) should have a description")
            XCTAssertFalse(error.errorDescription!.isEmpty, "Error description should not be empty")
        }
    }
    
    func testRestartTouchBarWithoutTouchBar() async {
        // This test should be run on a Mac without Touch Bar
        // or with mocked TouchBarManager
        
        // Mock scenario: no Touch Bar
        if !touchBarManager.hasTouchBar {
            let result = await touchBarManager.restartTouchBar()
            
            switch result {
            case .success:
                XCTFail("Should not succeed without Touch Bar")
            case .failure(let error):
                if case .noTouchBar = error {
                    // Expected error
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Expected noTouchBar error, got \(error)")
                }
            }
        }
    }
}

// Mock TouchBarManager for testing
class MockTouchBarManager: TouchBarManager {
    var mockHasTouchBar: Bool = false
    var mockProcessRunning: Bool = true
    
    override var hasTouchBar: Bool {
        get { mockHasTouchBar }
        set { mockHasTouchBar = newValue }
    }
    
    override func checkIfProcessRunning(_ processName: String) -> Bool {
        return mockProcessRunning
    }
}

final class MockTouchBarManagerTests: XCTestCase {
    func testMockWithoutTouchBar() async {
        let mockManager = MockTouchBarManager()
        mockManager.mockHasTouchBar = false
        
        let result = await mockManager.restartTouchBar()
        
        switch result {
        case .success:
            XCTFail("Should fail without Touch Bar")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "This device doesn't have a Touch Bar")
        }
    }
}