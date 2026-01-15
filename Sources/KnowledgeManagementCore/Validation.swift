import Foundation

public struct EntryValidator {
    public init() {}

    public func validate(title: String, content: String) throws {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.invalidTitle
        }
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError.invalidContent
        }
        if title.count > 200 {
            throw ValidationError.titleTooLong
        }
    }
}

public enum ValidationError: Error, LocalizedError {
    case invalidTitle
    case invalidContent
    case titleTooLong

    public var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Title must not be empty."
        case .invalidContent:
            return "Content must not be empty."
        case .titleTooLong:
            return "Title must be 200 characters or fewer."
        }
    }
}
