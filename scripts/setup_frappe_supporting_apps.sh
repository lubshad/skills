#!/usr/bin/env bash
# Compatibility entry point. Use sync_frappe_supporting_apps.sh for new commands.
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/sync_frappe_supporting_apps.sh" "$@"
