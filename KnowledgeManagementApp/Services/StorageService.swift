import Foundation

class StorageService {

    static let shared = StorageService()

    private init() {}

    private let entriesKey = "entries"

    func saveEntry(_ entry: Entry) {
        var entries = loadEntries()
        entries.append(entry)
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
    }

    func loadEntries() -> [Entry] {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([Entry].self, from: data) {
            return entries
        }
        return []
    }
}
