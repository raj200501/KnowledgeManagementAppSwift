import XCTest
@testable import KnowledgeManagementCore

final class ClassifierTests: XCTestCase {
    func testClassifierMatchesRules() {
        let rules = [
            ClassificationRule(label: "engineering", keywords: ["swift", "ios"], priority: 2),
            ClassificationRule(label: "product", keywords: ["roadmap"], priority: 1)
        ]
        let classifier = KeywordClassifier(rules: rules)
        let entry = Entry(title: "Swift tips", content: "CI for iOS", tags: [])

        let result = classifier.classify(entry: entry)

        XCTAssertEqual(result.label, "engineering")
        XCTAssertTrue(result.signals.contains("swift"))
    }

    func testClassifierFallsBackToGeneral() {
        let classifier = KeywordClassifier(rules: [])
        let entry = Entry(title: "Misc", content: "Notes", tags: [])

        let result = classifier.classify(entry: entry)

        XCTAssertEqual(result.label, "general")
        XCTAssertEqual(result.confidence, 0.4)
    }
}
