#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/public/css"
cp -a "$ROOT/resources/css/." "$ROOT/public/css/"
# Keep contrast notes out of the public serve path if present
rm -f "$ROOT/public/css/CONTRAST.md" "$ROOT/public/css/PHASE2.md" 2>/dev/null || true
echo "Synced resources/css -> public/css"
