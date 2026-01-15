import Foundation

public struct Entry: Codable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let content: String
    public let tags: [String]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public func updating(content: String, tags: [String]) -> Entry {
        Entry(
            id: id,
            title: title,
            content: content,
            tags: tags,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

public struct EntryEnvelope: Codable, Equatable {
    public let entry: Entry
    public let classification: ClassificationResult?

    public init(entry: Entry, classification: ClassificationResult?) {
        self.entry = entry
        self.classification = classification
    }
}
