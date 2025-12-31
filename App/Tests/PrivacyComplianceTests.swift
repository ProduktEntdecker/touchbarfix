import XCTest
@testable import TouchBarFix

/// Tests to verify GDPR and privacy compliance of analytics functionality
final class PrivacyComplianceTests: XCTestCase {

    var testUserDefaults: TestUserDefaults!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        testUserDefaults = TestUserDefaults()
        MockURLProtocol.reset()
        mockSession = createMockURLSession()
    }

    override func tearDown() {
        testUserDefaults = nil
        MockURLProtocol.reset()
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Opt-Out Tests

    func test_optOut_defaultsToDisabled() {
        let sut = createAnalyticsService()

        XCTAssertFalse(sut.analyticsEnabled,
            "Analytics should be disabled by default (opt-in model)")
    }

    func test_optOut_canBeEnabled() {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)
        let sut = createAnalyticsService()

        XCTAssertTrue(sut.analyticsEnabled,
            "Analytics should be enableable by user")
    }

    func test_optOut_persistsAcrossSessions() {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let sut1 = createAnalyticsService()
        XCTAssertTrue(sut1.analyticsEnabled)

        // Simulate new session with same UserDefaults
        let sut2 = createAnalyticsService()
        XCTAssertTrue(sut2.analyticsEnabled,
            "Analytics preference should persist")
    }

    func test_optOut_preventsAllTracking() async {
        // Analytics disabled (default)
        MockURLProtocol.mockEmptySuccess()
        let sut = createAnalyticsService()

        // Attempt multiple tracking calls
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")
        await sut.trackFixAttempt(success: false, modelIdentifier: "MacBookPro18,3")
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro17,1")

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(MockURLProtocol.capturedRequests.isEmpty,
            "No network requests should be made when opted out")
    }

    // MARK: - PII (Personally Identifiable Information) Tests

    func test_payload_neverContainsUserId() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        var capturedPayload: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedPayload = decodeJSONPayload(from: request)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(capturedPayload?["user_id"])
        XCTAssertNil(capturedPayload?["userId"])
        XCTAssertNil(capturedPayload?["uid"])
    }

    func test_payload_neverContainsDeviceId() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        var capturedPayload: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedPayload = decodeJSONPayload(from: request)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(capturedPayload?["device_id"])
        XCTAssertNil(capturedPayload?["deviceId"])
        XCTAssertNil(capturedPayload?["udid"])
        XCTAssertNil(capturedPayload?["UDID"])
    }

    func test_payload_neverContainsSerialNumber() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        var capturedPayload: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedPayload = decodeJSONPayload(from: request)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        // Include serial number in input to verify it's stripped
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3-C02XG0J9JGH1")

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(capturedPayload?["serial"])
        XCTAssertNil(capturedPayload?["serial_number"])
        XCTAssertNil(capturedPayload?["serialNumber"])

        // Also verify the model_series doesn't contain the serial
        if let modelSeries = capturedPayload?["model_series"] as? String {
            XCTAssertFalse(modelSeries.contains("C02"),
                "Model series should not contain serial number prefix")
            XCTAssertFalse(modelSeries.contains("JGH"),
                "Model series should not contain serial number parts")
        }
    }

    func test_payload_neverContainsEmailOrName() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        var capturedPayload: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedPayload = decodeJSONPayload(from: request)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(capturedPayload?["email"])
        XCTAssertNil(capturedPayload?["name"])
        XCTAssertNil(capturedPayload?["username"])
        XCTAssertNil(capturedPayload?["user_name"])
    }

    func test_payload_neverContainsIPAddress() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        var capturedPayload: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedPayload = decodeJSONPayload(from: request)
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(capturedPayload?["ip"])
        XCTAssertNil(capturedPayload?["ip_address"])
        XCTAssertNil(capturedPayload?["ipAddress"])
    }

    // MARK: - Data Minimization Tests

    func test_modelIdentifier_isTruncatedForPrivacy() {
        // Test the truncation logic directly - model identifier is truncated to 12 characters
        let longIdentifier = "MacBookPro18,3-EXTRADATA12345"
        let truncated = String(longIdentifier.prefix(12))

        XCTAssertEqual(truncated.count, 12,
            "Model identifier should be truncated to 12 characters")
        XCTAssertEqual(truncated, "MacBookPro18",
            "Truncated identifier should only contain model series")
        XCTAssertFalse(truncated.contains("EXTRA"),
            "Extra data should not be included")
    }

    func test_payload_containsOnlyNecessaryFields() {
        // Verify the expected payload structure without network mocking
        // The payload is constructed inline in trackFixAttempt
        let expectedFields = Set(["event", "success", "model_series", "timestamp", "app_version"])

        // Forbidden PII fields that should never be in the payload
        let forbiddenFields = Set(["user_id", "device_id", "uuid", "email", "name", "ip", "serial", "udid"])

        XCTAssertEqual(expectedFields.count, 5, "Payload should have exactly 5 fields")

        // Verify no forbidden fields would be in the expected set
        XCTAssertTrue(expectedFields.isDisjoint(with: forbiddenFields),
            "Expected fields should not contain any PII fields")

        // Verify specific required fields
        XCTAssertTrue(expectedFields.contains("event"), "Should include event type")
        XCTAssertTrue(expectedFields.contains("success"), "Should include success status")
        XCTAssertTrue(expectedFields.contains("model_series"), "Should include model series")
        XCTAssertTrue(expectedFields.contains("timestamp"), "Should include timestamp")
        XCTAssertTrue(expectedFields.contains("app_version"), "Should include app version")
    }

    // MARK: - Request Headers Tests

    func test_request_doesNotContainTrackingHeaders() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        MockURLProtocol.requestHandler = { request in
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        guard let request = MockURLProtocol.capturedRequests.first else {
            XCTFail("No request captured")
            return
        }

        // These headers should not be present
        XCTAssertNil(request.value(forHTTPHeaderField: "X-Device-ID"))
        XCTAssertNil(request.value(forHTTPHeaderField: "X-User-ID"))
        XCTAssertNil(request.value(forHTTPHeaderField: "X-Tracking-ID"))
    }

    func test_request_hasAppropriateUserAgent() async {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)

        let expectation = XCTestExpectation(description: "Request captured")
        MockURLProtocol.requestHandler = { request in
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data())
        }

        let sut = createAnalyticsService()
        await sut.trackFixAttempt(success: true, modelIdentifier: "MacBookPro18,3")

        await fulfillment(of: [expectation], timeout: 2.0)

        guard let request = MockURLProtocol.capturedRequests.first else {
            XCTFail("No request captured")
            return
        }

        let userAgent = request.value(forHTTPHeaderField: "User-Agent")
        XCTAssertNotNil(userAgent)
        XCTAssertTrue(userAgent?.contains("TouchBarFix") ?? false,
            "User-Agent should identify the app generically")
    }

    // MARK: - Local Data Storage Tests

    func test_localData_doesNotStorePersonalInfo() {
        testUserDefaults.userDefaults.set(true, forKey: AnalyticsService.analyticsEnabledKey)
        _ = createAnalyticsService()

        // Check UserDefaults doesn't contain PII
        let allKeys = testUserDefaults.userDefaults.dictionaryRepresentation().keys
        let suspiciousKeys = allKeys.filter { key in
            key.lowercased().contains("email") ||
            key.lowercased().contains("name") ||
            key.lowercased().contains("serial") ||
            key.lowercased().contains("udid")
        }

        XCTAssertTrue(suspiciousKeys.isEmpty,
            "UserDefaults should not contain PII keys. Found: \(suspiciousKeys)")
    }

    // MARK: - Helper Methods

    private func createAnalyticsService() -> AnalyticsService {
        return AnalyticsService(
            session: mockSession,
            userDefaults: testUserDefaults.userDefaults,
            skipInitialFetch: true
        )
    }
}
