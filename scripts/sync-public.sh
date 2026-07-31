#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/public/css" "$ROOT/public/js"
cp -a "$ROOT/resources/css/." "$ROOT/public/css/"
rm -f "$ROOT/public/css/CONTRAST.md" "$ROOT/public/css/"*.md 2>/dev/null || true
# public fonts.css uses relative paths
if [[ -f "$ROOT/public/css/base/fonts.css" ]]; then
  sed -i 's|url("/fonts/|url("../fonts/|g' "$ROOT/public/css/base/fonts.css"
fi
cp -a "$ROOT/resources/js/." "$ROOT/public/js/"
echo "Synced CSS + JS to public/"
