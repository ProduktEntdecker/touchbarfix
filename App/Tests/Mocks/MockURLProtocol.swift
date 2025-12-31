import Foundation

/// URLProtocol subclass for mocking network requests in tests
final class MockURLProtocol: URLProtocol {

    /// Handler called for each request. Set this in your test to define mock responses.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    /// Captured requests for verification
    static var capturedRequests: [URLRequest] = []

    /// Reset all mock state between tests
    static func reset() {
        requestHandler = nil
        capturedRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        MockURLProtocol.capturedRequests.append(request)

        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

/// Convenience methods for common mock scenarios
extension MockURLProtocol {

    /// Configure a successful JSON response
    static func mockSuccess(json: [String: Any], statusCode: Int = 200) {
        requestHandler = { request in
            let data = try JSONSerialization.data(withJSONObject: json)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, data)
        }
    }

    /// Configure an empty successful response
    static func mockEmptySuccess(statusCode: Int = 200) {
        requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
    }

    /// Configure a network error
    static func mockError(_ error: URLError.Code) {
        requestHandler = { _ in
            throw URLError(error)
        }
    }

    /// Configure a server error response
    static func mockServerError(statusCode: Int = 500) {
        requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
    }
}
