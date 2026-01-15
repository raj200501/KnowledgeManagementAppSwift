import XCTest
@testable import KnowledgeManagementCore

final class EntryStoreTests: XCTestCase {
    func testSaveAndLoad() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileURL = tempDir.appendingPathComponent("entries.json")
        let store = FileEntryStore(fileURL: fileURL)
        let entry = Entry(title: "Test", content: "Hello", tags: ["unit"]) 
        let envelope = EntryEnvelope(entry: entry, classification: nil)

        try store.save(envelope)
        let loaded = try store.loadAll()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.entry.title, "Test")
    }

    func testUpdate() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileURL = tempDir.appendingPathComponent("entries.json")
        let store = FileEntryStore(fileURL: fileURL)
        let entry = Entry(title: "Initial", content: "Body", tags: ["unit"])
        let envelope = EntryEnvelope(entry: entry, classification: nil)

        try store.save(envelope)
        let updatedEntry = entry.updating(content: "Updated", tags: ["updated"])
        let updatedEnvelope = EntryEnvelope(entry: updatedEntry, classification: nil)
        try store.update(updatedEnvelope)

        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.first?.entry.content, "Updated")
        XCTAssertEqual(loaded.first?.entry.tags, ["updated"])
    }

    func testDelete() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileURL = tempDir.appendingPathComponent("entries.json")
        let store = FileEntryStore(fileURL: fileURL)
        let entry = Entry(title: "Delete", content: "Body")
        let envelope = EntryEnvelope(entry: entry, classification: nil)

        try store.save(envelope)
        try store.delete(id: entry.id)

        let loaded = try store.loadAll()
        XCTAssertTrue(loaded.isEmpty)
    }
}
