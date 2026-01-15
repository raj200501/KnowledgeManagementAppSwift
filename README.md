# Knowledge Management App (Swift)

A Swift-based knowledge management tool with a deterministic CLI for capturing, classifying, storing, and uploading entries. The repository keeps the Swift iOS artifacts, but the canonical runnable experience is now the Swift Package Manager CLI (`kmapp`) that mirrors the original feature set (entry management, storage, classification, and network upload).

## Features

- Add, view, update, and delete knowledge entries.
- Local JSON storage with deterministic output.
- Keyword-based classification for predictable results.
- HTTP upload to integrate with external systems.
- Fully scriptable CLI with automated verification.

## Requirements

- macOS with Swift 5.9+ (Xcode or Swift toolchain).

## Quickstart (Verified)

```bash
swift build
.build/debug/kmapp init-config
.build/debug/kmapp add --title "Swift build notes" --content "CI should run swift test" --tags ios,swift
.build/debug/kmapp list
```

## Run Command

For convenience, use the provided script:

```bash
./scripts/run.sh
```

You can pass any CLI arguments to `scripts/run.sh`, for example:

```bash
./scripts/run.sh add --title "Release" --content "Ship it" --tags release
```

## Configuration

`kmapp` reads configuration from:

1. `--config <path>` if provided.
2. `./kmapp.config.json` (current directory).
3. `~/.kmapp/config.json`.
4. Built-in defaults if no config file exists.

Create a default config file:

```bash
.build/debug/kmapp init-config
```

See `samples/sample-config.json` for an example.

## Verified Verification

The canonical verification command is:

```bash
./scripts/verify.sh
```

It will:

1. Build the Swift package.
2. Run unit tests.
3. Add an entry and list it.
4. Spin up a local mock server and upload entries.
5. Run a classification check.

## CLI Usage

```bash
kmapp <command> [options]
```

Commands:

- `init-config`: write a default config JSON.
- `add`: create an entry.
- `list`: list all entries.
- `show`: show a specific entry.
- `update`: update an entry.
- `delete`: delete an entry.
- `classify`: classify a text snippet.
- `upload`: upload entries to an HTTP endpoint.
- `help`: show help output.

Run `kmapp help` for examples.

## Documentation

- `docs/CLI.md`: CLI reference and workflows.
- `docs/Architecture.md`: module overview.
- `docs/Reference.md`: configuration and schema reference.
- `docs/OperationalPlaybook.md`: templates for capturing operational knowledge.
- `docs/Troubleshooting.md`: common issues and fixes.

## Troubleshooting

If commands fail, review the troubleshooting guide in `docs/Troubleshooting.md`.

## CI

GitHub Actions runs `./scripts/verify.sh` on push and pull requests to ensure the README contract remains true.
