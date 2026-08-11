#!/usr/bin/env bash
# Build a GoDaddy-ready zip from public/ with files at the archive root.
# Output: dist/elessons-godaddy-public-html.zip (and optional ARTIFACTS_DIR copy)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBLIC="$ROOT/public"
OUT_DIR="${1:-$ROOT/dist}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-}"
ZIP_NAME="elessons-godaddy-public-html.zip"

if [[ ! -f "$PUBLIC/index.html" || ! -f "$PUBLIC/.htaccess" || ! -f "$PUBLIC/course-detail.html" ]]; then
  echo "ERROR: public/ is missing critical files (index.html, .htaccess, course-detail.html)" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
STAGE="$(mktemp -d)"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

cp -a "$PUBLIC"/. "$STAGE"/
find "$STAGE" -name '.DS_Store' -delete

# Refuse to ship Flutter/source leftovers if they somehow appear under public/
for bad in pubspec.yaml android lib/main.dart package.json vercel.json; do
  if [[ -e "$STAGE/$bad" ]]; then
    echo "ERROR: unexpected source file in package stage: $bad" >&2
    exit 1
  fi
done

(
  cd "$STAGE"
  zip -r -y "$OUT_DIR/$ZIP_NAME" . -x '*.DS_Store' -x '*__MACOSX*' >/dev/null
)

# Quick structure checks (avoid pipefail+grep -q SIGPIPE false negatives)
LISTING="$(unzip -l "$OUT_DIR/$ZIP_NAME")"
grep -E '[[:space:]]index\.html$' <<<"$LISTING" >/dev/null || {
  echo "ERROR: index.html not at zip root" >&2
  exit 1
}
grep -E '[[:space:]]\.htaccess$' <<<"$LISTING" >/dev/null || {
  echo "ERROR: .htaccess missing from zip" >&2
  exit 1
}
if grep -E 'public/index\.html|pubspec\.yaml|android/' <<<"$LISTING" >/dev/null; then
  echo "ERROR: zip contains nested/source paths" >&2
  exit 1
fi

if [[ -n "$ARTIFACTS_DIR" ]]; then
  mkdir -p "$ARTIFACTS_DIR"
  cp -f "$OUT_DIR/$ZIP_NAME" "$ARTIFACTS_DIR/$ZIP_NAME"
  echo "Copied to $ARTIFACTS_DIR/$ZIP_NAME"
fi

SIZE="$(du -h "$OUT_DIR/$ZIP_NAME" | awk '{print $1}')"
COUNT="$(unzip -l "$OUT_DIR/$ZIP_NAME" | tail -1 | awk '{print $2}')"
echo "OK: $OUT_DIR/$ZIP_NAME ($SIZE, $COUNT entries)"
echo "Upload to GoDaddy public_html, extract at top level, then delete the zip."
