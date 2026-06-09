#!/usr/bin/env bash
# Regenerate the sandbox Postman collection from the CatalogAPI OpenAPI spec.
#
# Pins a local copy of the spec, converts it to a Postman collection (one folder
# per tag), then forces the sandbox host and strips auth from public endpoints.
# Re-run whenever the API spec changes.
#
#   scripts/generate.sh             # fetch the latest spec, then convert + polish
#   scripts/generate.sh --no-fetch  # convert + polish from the pinned openapi.json
#
# Run from anywhere; outputs land in the v2/ root. Requires node/npx on PATH
# (mise provides it in this repo).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # scripts/
ROOT="$(dirname "$HERE")"                              # v2/
SPEC_URL="https://api.catalogapi.com/api/v2/openapi-clean"
SANDBOX_URL="https://api.catalogapi.com/sandbox/api/v2"
SPEC="$ROOT/openapi.json"
COLLECTION="$ROOT/postman/catalogapi.postman_collection.json"

mkdir -p "$ROOT/postman"

# 1. Pin the spec locally (skip with --no-fetch to reuse the committed copy).
if [[ "${1:-}" != "--no-fetch" ]]; then
  echo "Fetching spec -> $SPEC"
  curl -fsSL "$SPEC_URL" -o "$SPEC"
fi

# 2. Convert OpenAPI -> Postman collection, grouped into folders by tag.
echo "Converting spec -> Postman collection"
npx -y openapi-to-postmanv2 -s "$SPEC" -o "$COLLECTION" -p \
  -O folderStrategy=Tags,includeAuthInfoInExample=true

# 3. Make it sandbox-only and strip auth from public operations (e.g. /ping).
echo "Polishing collection"
node "$HERE/polish-postman.js" "$SPEC" "$COLLECTION" "$SANDBOX_URL"

# 4. Weld the hand-authored Order Lifecycle into the collection as a folder.
echo "Welding quickstart lifecycle folder"
node "$HERE/weld-lifecycle.js" "$COLLECTION"

echo "Done -> $COLLECTION"
