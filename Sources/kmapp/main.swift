import Foundation
import KnowledgeManagementCore

struct CLI {
    private let arguments: [String]
    private let logger = Logger()

    init(arguments: [String]) {
        self.arguments = arguments
    }

    func run() async -> Int32 {
        guard arguments.count >= 2 else {
            printHelp()
            return 1
        }

        let command = arguments[1]
        let options = parseOptions(Array(arguments.dropFirst(2)))

        do {
            switch command {
            case "init-config":
                try writeDefaultConfig(to: options)
                return 0
            case "add":
                try addEntry(options: options)
                return 0
            case "list":
                try listEntries(options: options)
                return 0
            case "show":
                try showEntry(options: options)
                return 0
            case "update":
                try updateEntry(options: options)
                return 0
            case "delete":
                try deleteEntry(options: options)
                return 0
            case "classify":
                try classifyEntry(options: options)
                return 0
            case "upload":
                try await uploadEntries(options: options)
                return 0
            case "help":
                printHelp()
                return 0
            default:
                logger.log("Unknown command: \(command)", level: .error)
                printHelp()
                return 1
            }
        } catch {
            logger.log(error.localizedDescription, level: .error)
            return 1
        }
    }

    private func parseOptions(_ args: [String]) -> [String: String] {
        var options: [String: String] = [:]
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg.hasPrefix("--") {
                let key = String(arg.dropFirst(2))
                let nextIndex = index + 1
                if nextIndex < args.count && !args[nextIndex].hasPrefix("--") {
                    options[key] = args[nextIndex]
                    index += 2
                } else {
                    options[key] = "true"
                    index += 1
                }
            } else {
                options["arg\(index)"] = arg
                index += 1
            }
        }
        return options
    }

    private func resolveConfig(options: [String: String]) throws -> AppConfig {
        let loader = ConfigLoader()
        let configURL = loader.resolveConfigURL(explicitPath: options["config"])
        if let configURL {
            return try AppConfig.load(from: configURL)
        }
        let home = FileManager.default.homeDirectoryForCurrentUser
        return AppConfig.defaultConfig(homeDirectory: home)
    }

    private func resolveStore(config: AppConfig, options: [String: String]) -> EntryStore {
        let storagePath = options["storage"] ?? config.storagePath
        let url = URL(fileURLWithPath: storagePath)
        return FileEntryStore(fileURL: url)
    }

    private func writeDefaultConfig(to options: [String: String]) throws {
        let destination = options["path"] ?? "kmapp.config.json"
        let home = FileManager.default.homeDirectoryForCurrentUser
        let config = AppConfig.defaultConfig(homeDirectory: home)
        let data = try JSONEncoder().encode(config)
        let url = URL(fileURLWithPath: destination)
        try data.write(to: url, options: [.atomic])
        logger.log("Wrote default config to \(destination)")
    }

    private func addEntry(options: [String: String]) throws {
        let title = options["title"] ?? ""
        let content = options["content"] ?? ""
        let tags = options["tags"]?.split(separator: ",").map { String($0) } ?? []
        let validator = EntryValidator()
        try validator.validate(title: title, content: content)

        let config = try resolveConfig(options: options)
        let classifier = KeywordClassifier(rules: config.classificationRules)
        let store = resolveStore(config: config, options: options)

        let entry = Entry(title: title, content: content, tags: tags.isEmpty ? config.defaultTags : tags)
        let classification = classifier.classify(entry: entry)
        let envelope = EntryEnvelope(entry: entry, classification: classification)
        try store.save(envelope)

        logger.log("Entry saved with id \(entry.id.uuidString)")
        printEnvelope(envelope)
    }

    private func listEntries(options: [String: String]) throws {
        let config = try resolveConfig(options: options)
        let store = resolveStore(config: config, options: options)
        let entries = try store.loadAll()
        if entries.isEmpty {
            logger.log("No entries found.")
            return
        }
        for envelope in entries {
            printEnvelope(envelope)
        }
    }

    private func showEntry(options: [String: String]) throws {
        guard let idValue = options["id"], let id = UUID(uuidString: idValue) else {
            throw ValidationError.invalidTitle
        }
        let config = try resolveConfig(options: options)
        let store = resolveStore(config: config, options: options)
        guard let envelope = try store.find(id: id) else {
            throw StorageError.entryNotFound
        }
        printEnvelope(envelope)
    }

    private func updateEntry(options: [String: String]) throws {
        guard let idValue = options["id"], let id = UUID(uuidString: idValue) else {
            throw ValidationError.invalidTitle
        }
        let config = try resolveConfig(options: options)
        let store = resolveStore(config: config, options: options)
        guard let existing = try store.find(id: id) else {
            throw StorageError.entryNotFound
        }

        let title = options["title"] ?? existing.entry.title
        let content = options["content"] ?? existing.entry.content
        let tags = options["tags"]?.split(separator: ",").map { String($0) } ?? existing.entry.tags

        let validator = EntryValidator()
        try validator.validate(title: title, content: content)

        let classifier = KeywordClassifier(rules: config.classificationRules)
        let entry = Entry(
            id: existing.entry.id,
            title: title,
            content: content,
            tags: tags,
            createdAt: existing.entry.createdAt,
            updatedAt: Date()
        )
        let classification = classifier.classify(entry: entry)
        let envelope = EntryEnvelope(entry: entry, classification: classification)
        try store.update(envelope)
        printEnvelope(envelope)
    }

    private func deleteEntry(options: [String: String]) throws {
        guard let idValue = options["id"], let id = UUID(uuidString: idValue) else {
            throw ValidationError.invalidTitle
        }
        let config = try resolveConfig(options: options)
        let store = resolveStore(config: config, options: options)
        try store.delete(id: id)
        logger.log("Deleted entry \(id.uuidString)")
    }

    private func classifyEntry(options: [String: String]) throws {
        let title = options["title"] ?? ""
        let content = options["content"] ?? ""
        let validator = EntryValidator()
        try validator.validate(title: title, content: content)

        let config = try resolveConfig(options: options)
        let classifier = KeywordClassifier(rules: config.classificationRules)
        let entry = Entry(title: title, content: content, tags: config.defaultTags)
        let result = classifier.classify(entry: entry)
        printClassification(result)
    }

    private func uploadEntries(options: [String: String]) async throws {
        let config = try resolveConfig(options: options)
        let store = resolveStore(config: config, options: options)
        let entries = try store.loadAll()
        let endpoint = URL(string: options["endpoint"] ?? config.uploadEndpoint)
        guard let endpoint else {
            throw ValidationError.invalidTitle
        }
        let client = NetworkClient()
        let response = try await client.upload(entries: entries, endpoint: endpoint, timeout: 10)
        logger.log("Upload response: \(response.status) | received \(response.received)")
    }

    private func printEnvelope(_ envelope: EntryEnvelope) {
        let entry = envelope.entry
        let formattedDate = ISO8601DateFormatter().string(from: entry.updatedAt)
        print("ID: \(entry.id.uuidString)")
        print("Title: \(entry.title)")
        print("Content: \(entry.content)")
        print("Tags: \(entry.tags.joined(separator: ", "))")
        print("Updated: \(formattedDate)")
        if let classification = envelope.classification {
            print("Classification: \(classification.label) (\(classification.confidence))")
            if !classification.signals.isEmpty {
                print("Signals: \(classification.signals.joined(separator: ", "))")
            }
        }
        print("---")
    }

    private func printClassification(_ result: ClassificationResult) {
        print("Label: \(result.label)")
        print("Confidence: \(String(format: "%.2f", result.confidence))")
        if !result.signals.isEmpty {
            print("Signals: \(result.signals.joined(separator: ", "))")
        }
    }

    private func printHelp() {
        print("""
        Knowledge Management App (CLI)

        Usage:
          kmapp <command> [options]

        Commands:
          init-config           Write a default config file.
          add                   Add a new entry.
          list                  List all entries.
          show                  Show a specific entry.
          update                Update an entry.
          delete                Delete an entry.
          classify              Classify text without saving.
          upload                Upload entries to an HTTP endpoint.
          help                  Show this help.

        Global options:
          --config <path>       Path to config JSON.
          --storage <path>      Override storage path.

        Command options:
          add --title <title> --content <content> [--tags tag1,tag2]
          show --id <uuid>
          update --id <uuid> [--title <title>] [--content <content>] [--tags tag1,tag2]
          delete --id <uuid>
          classify --title <title> --content <content>
          upload [--endpoint <url>]

        Examples:
          kmapp init-config
          kmapp add --title "Swift notes" --content "Remember to test" --tags ios,swift
          kmapp list
          kmapp classify --title "Build" --content "CI pipeline"
          kmapp upload --endpoint http://127.0.0.1:8081/upload
        """)
    }
}

@main
enum Main {
    static func main() async {
        let cli = CLI(arguments: CommandLine.arguments)
        let exitCode = await cli.run()
        exit(exitCode)
    }
}
