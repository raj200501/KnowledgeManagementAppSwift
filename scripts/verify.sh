#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

swift build
swift test

TMP_DIR="$(mktemp -d)"
CONFIG_PATH="$TMP_DIR/config.json"
STORAGE_PATH="$TMP_DIR/entries.json"

.build/debug/kmapp init-config --path "$CONFIG_PATH"

.build/debug/kmapp add \
  --config "$CONFIG_PATH" \
  --storage "$STORAGE_PATH" \
  --title "Swift build notes" \
  --content "CI should run swift test" \
  --tags ios,swift

LIST_OUTPUT=$(.build/debug/kmapp list --config "$CONFIG_PATH" --storage "$STORAGE_PATH")

echo "$LIST_OUTPUT" | grep "Swift build notes"

echo "Starting mock server"
python3 scripts/mock_server.py 8081 > "$TMP_DIR/server.log" 2>&1 &
SERVER_PID=$!

sleep 1

.build/debug/kmapp upload --config "$CONFIG_PATH" --storage "$STORAGE_PATH" --endpoint "http://127.0.0.1:8081/upload"

kill "$SERVER_PID"

.build/debug/kmapp classify --config "$CONFIG_PATH" --title "Roadmap" --content "Feature planning" | grep "Label: product"

rm -rf "$TMP_DIR"
