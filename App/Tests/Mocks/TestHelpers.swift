import Foundation
import XCTest

/// Creates an isolated UserDefaults instance for testing
/// Automatically cleans up when deallocated
final class TestUserDefaults {
    let userDefaults: UserDefaults
    private let suiteName: String

    init() {
        suiteName = "test-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
    }

    deinit {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    /// Clear all values
    func reset() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}

/// Creates a URLSession configured with MockURLProtocol
func createMockURLSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

/// XCTest extension for async convenience
extension XCTestCase {

    /// Wait for an async operation with timeout
    func waitForAsync(
        timeout: TimeInterval = 5.0,
        _ operation: @escaping () async -> Void
    ) {
        let expectation = XCTestExpectation(description: "Async operation")

        Task {
            await operation()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }
}

/// Decode JSON payload from URLRequest body
func decodeJSONPayload(from request: URLRequest) -> [String: Any]? {
    guard let body = request.httpBody else { return nil }
    return try? JSONSerialization.jsonObject(with: body) as? [String: Any]
}

/// Check if array of captured requests contains request to specific path
func hasRequestToPath(_ path: String, in requests: [URLRequest]) -> Bool {
    return requests.contains { request in
        request.url?.path.contains(path) ?? false
    }
}
