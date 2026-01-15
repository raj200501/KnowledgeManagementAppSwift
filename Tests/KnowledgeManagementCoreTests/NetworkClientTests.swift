import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import KnowledgeManagementCore

final class NetworkClientTests: XCTestCase {
    func testUploadHandlesSuccess() async throws {
        let handler: MockURLProtocol.Handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let response = UploadResponse(status: "ok", received: 1, timestamp: "now")
            let data = try JSONEncoder().encode(response)
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.handler = handler
        let session = URLSession(configuration: configuration)

        let client = NetworkClientWithSession(session: session)
        let entry = Entry(title: "Test", content: "Body", tags: [])
        let response = try await client.upload(entries: [EntryEnvelope(entry: entry, classification: nil)], endpoint: URL(string: "http://localhost")!, timeout: 5)

        XCTAssertEqual(response.status, "ok")
    }
}

final class MockURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) throws -> (HTTPURLResponse, Data)
    static var handler: Handler?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.handler else {
            fatalError("Handler not set")
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

struct NetworkClientWithSession: NetworkUploading {
    let session: URLSession

    func upload(entries: [EntryEnvelope], endpoint: URL, timeout: TimeInterval) async throws -> UploadResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(entries)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode(UploadResponse.self, from: data)
    }
}
