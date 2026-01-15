# Knowledge Management App CLI Guide

This document is a deep dive into the CLI provided by the Knowledge Management App. It covers installation, command reference, behaviors, and practical patterns for daily use. The CLI is designed to be deterministic and scriptable, so you can automate knowledge capture and reporting without manual UI steps.

## Installation Overview

The CLI is built with Swift Package Manager (SwiftPM). That means you can build the tool on macOS with the system Swift toolchain and no additional dependencies.

```bash
swift build
```

The executable will be available at `.build/debug/kmapp`.

## Command Summary

| Command | Purpose | Typical Use |
| --- | --- | --- |
| `init-config` | Writes a default configuration file. | Set up a starting `kmapp.config.json`. |
| `add` | Add a new entry with classification. | Capture notes in your workflow. |
| `list` | List all stored entries. | Review your knowledge base. |
| `show` | Show one entry by UUID. | Inspect a specific entry. |
| `update` | Update entry fields and reclassify. | Correct or refine notes. |
| `delete` | Remove an entry by UUID. | Clean up temporary notes. |
| `classify` | Run classification without saving. | Preview ML-style classification. |
| `upload` | Upload entries to an HTTP endpoint. | Integrate with upstream systems. |

## Config File Format

`kmapp` reads configuration from a JSON file. The default location is `./kmapp.config.json` (current working directory). If it does not exist, the CLI looks in `~/.kmapp/config.json`. You can provide a custom path using `--config`.

```json
{
  "storagePath": "/Users/me/.kmapp/entries.json",
  "defaultTags": ["inbox"],
  "classificationRules": [
    {
      "label": "engineering",
      "keywords": ["swift", "ios", "xcode", "build", "ci"],
      "priority": 3
    }
  ],
  "uploadEndpoint": "http://127.0.0.1:8081/upload"
}
```

### Required Fields

- `storagePath`: Absolute path for the JSON storage file. The file will be created on demand.
- `defaultTags`: Tags used when no tags are provided for a new entry.
- `classificationRules`: Array of rules that drive deterministic classification.
- `uploadEndpoint`: Base URL for `upload` requests.

### Optional Behavior

If the config file is missing entirely, the CLI uses a safe default configuration with the storage file at `~/.kmapp/entries.json` and a built-in set of classification rules.

## Entry Data Model

Entries are stored as JSON objects with the following fields:

- `id` (UUID): unique identifier.
- `title`: short summary.
- `content`: the main text body.
- `tags`: list of tags for search and grouping.
- `createdAt`: creation timestamp in ISO-8601 format.
- `updatedAt`: last-updated timestamp in ISO-8601 format.

A stored entry is wrapped in an envelope that also includes the most recent classification result.

## Detailed Command Guide

### `init-config`

Create a default config file in the current working directory.

```bash
kmapp init-config
```

You can also write to an explicit path:

```bash
kmapp init-config --path ./kmapp.config.json
```

### `add`

Create and store a new entry. Titles and content are required. Tags are optional.

```bash
kmapp add --title "Swift notes" --content "Remember to run swift test" --tags ios,swift
```

Behavior notes:

- The CLI validates the title and content before saving.
- If tags are omitted, the configuration `defaultTags` is used instead.
- Entries are classified immediately upon creation.

### `list`

List all entries in storage. Useful for quick reporting.

```bash
kmapp list
```

### `show`

Display a single entry by UUID.

```bash
kmapp show --id 1E3F2B7C-7B4F-4A2B-9E4D-3F4C66B1B2B1
```

### `update`

Update fields for a specific entry. Fields not supplied are preserved.

```bash
kmapp update --id 1E3F2B7C-7B4F-4A2B-9E4D-3F4C66B1B2B1 \
  --content "Updated with new context" \
  --tags ios,swift,release
```

The entry is reclassified after update.

### `delete`

Remove an entry by UUID.

```bash
kmapp delete --id 1E3F2B7C-7B4F-4A2B-9E4D-3F4C66B1B2B1
```

### `classify`

Classify ad-hoc content without saving it. This is handy when you want to see how the rules behave before adding data.

```bash
kmapp classify --title "Incident" --content "Postmortem review"
```

### `upload`

Upload entries to a remote HTTP service. The CLI sends a POST request with JSON body matching the stored entries.

```bash
kmapp upload --endpoint http://127.0.0.1:8081/upload
```

## Output Format

Entries are printed using a human readable format:

```
ID: <uuid>
Title: <title>
Content: <content>
Tags: tag1, tag2
Updated: <timestamp>
Classification: <label> (<confidence>)
Signals: keyword1, keyword2
---
```

## Automation Patterns

### Add and list in one script

```bash
kmapp add --title "Retro" --content "Sprint summary" --tags sprint
kmapp list | grep "Retro"
```

### Validate classification rules

```bash
kmapp classify --title "Swift builds" --content "CI pipeline broke on iOS"
```

### Bulk upload

```bash
kmapp upload --endpoint https://example.com/upload
```

## Best Practices

1. Keep titles short and descriptive.
2. Use consistent tags for easier grouping (e.g., `release`, `incident`, `research`).
3. Ensure your `storagePath` is on a filesystem you can back up.
4. Run `kmapp list` before upload to ensure entries are correct.

## Security Notes

The CLI stores data in plaintext JSON. If you handle sensitive data, encrypt the storage file at rest (for example, using macOS FileVault or storing within an encrypted container).

## Troubleshooting Quick Links

- Missing config file: run `kmapp init-config`.
- Validation failures: ensure title and content are non-empty.
- Upload failures: verify the endpoint and connectivity.

For more troubleshooting, see `docs/Troubleshooting.md`.
