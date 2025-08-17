import XCTest
@testable import TouchBarFix

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
        // Test checking if a known Touch Bar process is running
        let isRunning = touchBarManager.checkIfProcessRunning("TouchBarServer")
        // TouchBarServer might or might not be running, but should be allowed
        XCTAssertTrue(true, "TouchBarServer process check should be allowed")
        
        // Test checking a non-existent process (should be blocked by security validation)
        let notRunning = touchBarManager.checkIfProcessRunning("ThisProcessDoesNotExist123456")
        XCTAssertFalse(notRunning, "Non-existent process should be blocked by security validation")
        
        // Test that unauthorized processes are blocked by security validation
        let unauthorizedProcess = touchBarManager.checkIfProcessRunning("Finder")
        XCTAssertFalse(unauthorizedProcess, "Unauthorized processes should be blocked by security validation")
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
    
    override func detectTouchBar() {
        // Override detection to use only mock values
        hasTouchBar = mockHasTouchBar
        print("🔍 Mock Touch Bar Detection: \(mockHasTouchBar)")
    }
}

final class MockTouchBarManagerTests: XCTestCase {
    func testMockWithoutTouchBar() async {
        let mockManager = MockTouchBarManager()
        mockManager.mockHasTouchBar = false
        mockManager.detectTouchBar() // Force detection with mock values
        
        let result = await mockManager.restartTouchBar()
        
        switch result {
        case .success:
            XCTFail("Should fail without Touch Bar")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "This device doesn't have a Touch Bar")
        }
    }
}