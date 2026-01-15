import Foundation

public struct ClassificationResult: Codable, Equatable {
    public let label: String
    public let confidence: Double
    public let signals: [String]

    public init(label: String, confidence: Double, signals: [String]) {
        self.label = label
        self.confidence = confidence
        self.signals = signals
    }
}

public protocol EntryClassifier {
    func classify(entry: Entry) -> ClassificationResult
}

public struct KeywordClassifier: EntryClassifier {
    private let rules: [ClassificationRule]

    public init(rules: [ClassificationRule]) {
        self.rules = rules
    }

    public func classify(entry: Entry) -> ClassificationResult {
        let content = [entry.title, entry.content].joined(separator: " ").lowercased()
        var bestMatch: ClassificationRule?
        var matchedSignals: [String] = []

        for rule in rules {
            let matches = rule.keywords.filter { content.contains($0.lowercased()) }
            if !matches.isEmpty {
                matchedSignals.append(contentsOf: matches)
                if bestMatch == nil || rule.priority > bestMatch?.priority ?? 0 {
                    bestMatch = rule
                }
            }
        }

        let label = bestMatch?.label ?? "general"
        let confidence = bestMatch != nil ? 0.82 : 0.4
        let signals = Array(Set(matchedSignals)).sorted()
        return ClassificationResult(label: label, confidence: confidence, signals: signals)
    }
}

public struct ClassificationRule: Codable, Equatable {
    public let label: String
    public let keywords: [String]
    public let priority: Int

    public init(label: String, keywords: [String], priority: Int) {
        self.label = label
        self.keywords = keywords
        self.priority = priority
    }
}
