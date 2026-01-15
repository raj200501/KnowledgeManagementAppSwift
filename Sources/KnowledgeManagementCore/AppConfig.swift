import Foundation

public struct AppConfig: Codable, Equatable {
    public let storagePath: String
    public let defaultTags: [String]
    public let classificationRules: [ClassificationRule]
    public let uploadEndpoint: String

    public init(
        storagePath: String,
        defaultTags: [String],
        classificationRules: [ClassificationRule],
        uploadEndpoint: String
    ) {
        self.storagePath = storagePath
        self.defaultTags = defaultTags
        self.classificationRules = classificationRules
        self.uploadEndpoint = uploadEndpoint
    }

    public static func load(from url: URL) throws -> AppConfig {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(AppConfig.self, from: data)
    }

    public static func defaultConfig(homeDirectory: URL) -> AppConfig {
        let storagePath = homeDirectory.appendingPathComponent(".kmapp/entries.json").path
        return AppConfig(
            storagePath: storagePath,
            defaultTags: ["inbox"],
            classificationRules: [
                ClassificationRule(label: "engineering", keywords: ["swift", "ios", "xcode", "build", "ci"], priority: 3),
                ClassificationRule(label: "product", keywords: ["roadmap", "planning", "feature"], priority: 2),
                ClassificationRule(label: "research", keywords: ["paper", "study", "experiment"], priority: 2),
                ClassificationRule(label: "operations", keywords: ["incident", "postmortem", "deployment"], priority: 1)
            ],
            uploadEndpoint: "http://127.0.0.1:8081/upload"
        )
    }
}

public struct ConfigLoader {
    public let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func resolveConfigURL(explicitPath: String?) -> URL? {
        if let explicitPath {
            return URL(fileURLWithPath: explicitPath)
        }

        let currentDirectory = fileManager.currentDirectoryPath
        let local = URL(fileURLWithPath: currentDirectory).appendingPathComponent("kmapp.config.json")
        if fileManager.fileExists(atPath: local.path) {
            return local
        }

        let home = fileManager.homeDirectoryForCurrentUser
        let homeConfig = home.appendingPathComponent(".kmapp/config.json")
        if fileManager.fileExists(atPath: homeConfig.path) {
            return homeConfig
        }

        return nil
    }
}
