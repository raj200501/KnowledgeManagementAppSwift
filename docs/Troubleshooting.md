# Troubleshooting Guide

This document lists common issues and deterministic fixes for the Knowledge Management App CLI.

## Build Issues

### `swift: command not found`

Ensure you have a Swift toolchain installed. On macOS, install Xcode and run:

```bash
xcode-select --install
```

### Build fails due to missing SDK

Open Xcode once to complete installation of required components. Then rerun:

```bash
swift build
```

## Runtime Issues

### `Title must not be empty`

You attempted to add or classify with an empty title. Provide a `--title` argument:

```bash
kmapp add --title "Example" --content "Valid content"
```

### `Content must not be empty`

You attempted to add or classify with an empty content field. Provide `--content`:

```bash
kmapp add --title "Example" --content "Valid content"
```

### `Entry not found`

The UUID passed to `show`, `update`, or `delete` does not exist in the storage file. Use `kmapp list` to get valid IDs.

### Upload fails with status 404

The endpoint provided does not contain `/upload` or the server is not running. Confirm the endpoint matches the server path. For the mock server, use:

```bash
kmapp upload --endpoint http://127.0.0.1:8081/upload
```

### Upload fails with status 500

Your server is rejecting the request. Verify that it accepts JSON and returns a valid response body that matches `UploadResponse`.

## Configuration Issues

### No config file found

If no config exists in the current directory or in `~/.kmapp/config.json`, the CLI uses a default configuration. You can create a config file with:

```bash
kmapp init-config
```

### Storage path is invalid

If the configured storage path points to a directory that does not exist, the CLI creates the directory automatically. If permission is denied, pick a location inside your home directory:

```json
{
  "storagePath": "/Users/you/.kmapp/entries.json"
}
```

## Data Issues

### Duplicate entries

Each entry gets a unique UUID. If you see duplicate titles, they are distinct entries. Use `show` or `update` to inspect and edit the correct one.

### Cannot parse storage file

If the JSON file is manually edited and becomes invalid, the CLI will not load entries. Restore from a backup or recreate the file by moving it aside and re-adding entries.

## Networking Issues

### Timeout

The upload command defaults to a 10 second timeout. Ensure the endpoint responds promptly. If you need a longer timeout, consider updating the configuration and rebuilding with a custom change.

### SSL Errors

If using HTTPS, ensure your server certificate is valid and trusted on the system.

## Logging Tips

All CLI operations emit timestamped logs. Use `grep` or `tee` to capture them in scripts:

```bash
kmapp add --title "Log demo" --content "Logging" | tee /tmp/kmapp.log
```

## Additional Help

If issues persist, inspect `docs/CLI.md` and `docs/Architecture.md` for deeper context on how the CLI works.
