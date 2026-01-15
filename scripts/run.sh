#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

swift build

if [[ $# -eq 0 ]]; then
  echo "Running kmapp help..."
  .build/debug/kmapp help
else
  .build/debug/kmapp "$@"
fi
