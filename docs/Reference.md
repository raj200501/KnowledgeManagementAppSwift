# Knowledge Management App Reference

This reference is intended for engineers automating workflows around `kmapp`. It describes configuration, schema, commands, and workflows in detail.

## Configuration Schema

### Top-level keys

- `storagePath` (string, required)
- `defaultTags` (array of string, required)
- `classificationRules` (array of objects, required)
- `uploadEndpoint` (string, required)

### `classificationRules` object

Each rule has the following keys:

- `label` (string, required)
- `keywords` (array of string, required)
- `priority` (int, required)

### Example

```json
{
  "storagePath": "/Users/me/.kmapp/entries.json",
  "defaultTags": ["inbox"],
  "classificationRules": [
    {
      "label": "engineering",
      "keywords": ["swift", "ios", "xcode", "build", "ci"],
      "priority": 3
    },
    {
      "label": "product",
      "keywords": ["roadmap", "planning", "feature"],
      "priority": 2
    },
    {
      "label": "research",
      "keywords": ["paper", "study", "experiment"],
      "priority": 2
    },
    {
      "label": "operations",
      "keywords": ["incident", "postmortem", "deployment"],
      "priority": 1
    }
  ],
  "uploadEndpoint": "http://127.0.0.1:8081/upload"
}
```

## Environment Variables

The CLI does not require environment variables. When used in automation, it is recommended to set `HOME` explicitly so the storage path resolves deterministically.

## Storage File

The storage file is a JSON array. Each item is an envelope:

- `entry` object
- `classification` object (optional, but present on all stored entries)

### `entry` fields

- `id` (UUID)
- `title` (string)
- `content` (string)
- `tags` (array)
- `createdAt` (ISO-8601 string)
- `updatedAt` (ISO-8601 string)

### `classification` fields

- `label` (string)
- `confidence` (number)
- `signals` (array of string)

## CLI Exit Codes

- `0`: success
- `1`: error (validation, storage, or network failure)

## Command Reference

### `init-config`

Creates a config file at the requested path or current directory.

Options:

- `--path`: destination path for config JSON.

### `add`

Add a new entry.

Options:

- `--title`: entry title (required)
- `--content`: entry content (required)
- `--tags`: comma-separated list of tags (optional)
- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

### `list`

List all entries.

Options:

- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

### `show`

Show a single entry by UUID.

Options:

- `--id`: entry UUID (required)
- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

### `update`

Update an entry by UUID.

Options:

- `--id`: entry UUID (required)
- `--title`: new title (optional)
- `--content`: new content (optional)
- `--tags`: new tags (optional)
- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

### `delete`

Delete an entry by UUID.

Options:

- `--id`: entry UUID (required)
- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

### `classify`

Classify text without saving.

Options:

- `--title`: title to classify (required)
- `--content`: content to classify (required)
- `--config`: config file path (optional)

### `upload`

Upload entries to an HTTP endpoint.

Options:

- `--endpoint`: upload URL (optional; defaults to config `uploadEndpoint`)
- `--config`: config file path (optional)
- `--storage`: override storage path (optional)

## Example Scenarios

### Daily Review

1. Add daily notes:

```bash
kmapp add --title "Daily Standup" --content "Reviewed backlog" --tags scrum
```

2. List entries:

```bash
kmapp list
```

3. Upload for archiving:

```bash
kmapp upload --endpoint https://archive.example.com/upload
```

### Incident Capture

1. Add incident notes:

```bash
kmapp add --title "Incident 312" --content "DB failover" --tags incident,ops
```

2. Run classification check:

```bash
kmapp classify --title "Incident 312" --content "Postmortem review"
```

3. Update with final notes:

```bash
kmapp update --id <uuid> --content "Resolved" --tags incident,postmortem
```

## Integrations

The upload endpoint can be implemented by any service that accepts JSON arrays of envelopes and returns a response like:

```json
{
  "status": "ok",
  "received": 2,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Validation Rules

Validation rules are enforced for data quality:

- Title must not be empty.
- Content must not be empty.
- Title length must be <= 200 characters.

## Glossary

- **Entry**: A single knowledge item.
- **Envelope**: Entry + classification metadata.
- **Classification rule**: Keyword-based mapping to a label.
- **Signal**: Matched keyword.
