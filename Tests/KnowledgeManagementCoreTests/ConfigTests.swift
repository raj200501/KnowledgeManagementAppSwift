import XCTest
@testable import KnowledgeManagementCore

final class ConfigTests: XCTestCase {
    func testDefaultConfigIncludesStoragePath() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let config = AppConfig.defaultConfig(homeDirectory: home)

        XCTAssertTrue(config.storagePath.contains(".kmapp/entries.json"))
        XCTAssertFalse(config.classificationRules.isEmpty)
    }

    func testConfigLoaderPrefersExplicitPath() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let configURL = tempDir.appendingPathComponent("config.json")
        let config = AppConfig(storagePath: "/tmp/entries.json", defaultTags: ["x"], classificationRules: [], uploadEndpoint: "http://localhost")
        let data = try JSONEncoder().encode(config)
        try data.write(to: configURL)

        let loader = ConfigLoader()
        let resolved = loader.resolveConfigURL(explicitPath: configURL.path)

        XCTAssertEqual(resolved?.path, configURL.path)
    }
}
