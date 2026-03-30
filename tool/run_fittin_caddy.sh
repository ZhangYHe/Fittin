#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CADDY_BIN="${CADDY_BIN:-$(command -v caddy)}"
CONFIG_PATH="$REPO_ROOT/deploy/caddy/fittin.Caddyfile"

if [[ -z "${CADDY_BIN:-}" ]]; then
  echo "caddy not found in PATH" >&2
  exit 1
fi

cd "$REPO_ROOT"
exec "$CADDY_BIN" run --config "$CONFIG_PATH"
