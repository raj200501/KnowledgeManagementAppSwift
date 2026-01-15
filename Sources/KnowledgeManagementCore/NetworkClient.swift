import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct UploadResponse: Codable, Equatable {
    public let status: String
    public let received: Int
    public let timestamp: String

    public init(status: String, received: Int, timestamp: String) {
        self.status = status
        self.received = received
        self.timestamp = timestamp
    }
}

public protocol NetworkUploading {
    func upload(entries: [EntryEnvelope], endpoint: URL, timeout: TimeInterval) async throws -> UploadResponse
}

public struct NetworkClient: NetworkUploading {
    public init() {}

    public func upload(entries: [EntryEnvelope], endpoint: URL, timeout: TimeInterval = 10) async throws -> UploadResponse {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(entries)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(UploadResponse.self, from: data)
    }
}

public enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Network response was invalid."
        case .httpStatus(let status):
            return "Network request failed with status \(status)."
        }
    }
}
