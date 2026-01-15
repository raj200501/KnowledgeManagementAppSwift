# Architecture Overview

This document explains the core architecture of the Knowledge Management App CLI implementation. The CLI shares concepts with the original iOS app (entries, storage, classification) while providing a deterministic workflow for automation and CI.

## Modules

### KnowledgeManagementCore

The core Swift module defines the following responsibilities:

- **Entry**: the domain model for knowledge items.
- **EntryEnvelope**: persisted wrapper containing the entry and its classification.
- **EntryStore**: protocol for persistence.
- **FileEntryStore**: JSON-backed storage implementation.
- **Classification**: deterministic keyword-based classifier.
- **NetworkClient**: HTTP uploader for entry envelopes.
- **AppConfig**: configuration schema and loader.
- **Validation**: preflight checks for title and content fields.
- **Logger**: structured console output.

These components are composed by the CLI executable but remain decoupled for unit testing.

## Data Flow

The high-level flow for adding an entry is:

1. CLI parses arguments.
2. CLI loads configuration (`AppConfig`).
3. CLI validates title/content (`EntryValidator`).
4. CLI creates a new `Entry` with tags.
5. CLI runs `KeywordClassifier` using `classificationRules`.
6. CLI wraps entry + classification in an `EntryEnvelope`.
7. CLI writes the envelope into the `FileEntryStore`.
8. CLI prints the envelope summary to stdout.

## Storage Format

The storage file is a JSON array. Each item is an object with two keys:

- `entry`: the `Entry` payload.
- `classification`: the `ClassificationResult` payload.

This is intentionally simple so users can inspect or back up data without dedicated tooling.

Example layout:

```json
[
  {
    "entry": {
      "id": "...",
      "title": "Release notes",
      "content": "Build is green",
      "tags": ["release"],
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    },
    "classification": {
      "label": "engineering",
      "confidence": 0.82,
      "signals": ["build"]
    }
  }
]
```

## Classification Rules

The classifier is intentionally deterministic (no external ML model dependency) to ensure tests and automation are reliable. Each rule has:

- `label`: the resulting category.
- `keywords`: case-insensitive tokens to match.
- `priority`: tie-breaker; higher wins.

When multiple rules match, the highest priority rule wins. Signals include all matched keywords.

## Networking

Uploads are performed via HTTP POST with a JSON body. The upload response must contain:

- `status`: human-readable string.
- `received`: count of entries received.
- `timestamp`: server timestamp or placeholder.

This is simple by design so that mock servers can be used in CI.

## Error Handling

Errors fall into a few categories:

- `ValidationError`: invalid titles/content.
- `StorageError`: missing entries or storage failures.
- `NetworkError`: unexpected response or status codes.

The CLI catches errors and prints them with the logger. It then exits with a non-zero exit code.

## Extensibility

The CLI is designed to evolve. Additional features could include:

- Alternate storage backends (e.g., SQLite).
- Additional classifiers (vector, ML-based, etc.).
- Encryption for storage at rest.
- Sync operations with remote APIs.

The current design keeps core logic in `KnowledgeManagementCore` so alternative front-ends can reuse it, including potential future iOS or macOS apps.
