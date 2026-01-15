import Foundation

public protocol EntryStore {
    func loadAll() throws -> [EntryEnvelope]
    func save(_ envelope: EntryEnvelope) throws
    func update(_ envelope: EntryEnvelope) throws
    func delete(id: UUID) throws
    func find(id: UUID) throws -> EntryEnvelope?
}

public struct FileEntryStore: EntryStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager

    public init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    public func loadAll() throws -> [EntryEnvelope] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([EntryEnvelope].self, from: data)
    }

    public func save(_ envelope: EntryEnvelope) throws {
        var entries = try loadAll()
        entries.append(envelope)
        try write(entries)
    }

    public func update(_ envelope: EntryEnvelope) throws {
        var entries = try loadAll()
        guard let index = entries.firstIndex(where: { $0.entry.id == envelope.entry.id }) else {
            throw StorageError.entryNotFound
        }
        entries[index] = envelope
        try write(entries)
    }

    public func delete(id: UUID) throws {
        var entries = try loadAll()
        entries.removeAll { $0.entry.id == id }
        try write(entries)
    }

    public func find(id: UUID) throws -> EntryEnvelope? {
        try loadAll().first { $0.entry.id == id }
    }

    private func write(_ entries: [EntryEnvelope]) throws {
        let data = try encoder.encode(entries)
        let directory = fileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        try data.write(to: fileURL, options: [.atomic])
    }
}

public enum StorageError: Error, LocalizedError {
    case entryNotFound

    public var errorDescription: String? {
        switch self {
        case .entryNotFound:
            return "Entry not found."
        }
    }
}
