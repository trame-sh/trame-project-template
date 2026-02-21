#!/usr/bin/env bash
set -euo pipefail

REPO="trame-sh/trame-tools"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/.trame-tools-version"

get_latest_version() {
  curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
}

# --check / -c: compare local version against latest release
if [ "${1:-}" = "--check" ] || [ "${1:-}" = "-c" ]; then
  LATEST=$(get_latest_version)
  if [ -f "$VERSION_FILE" ]; then
    CURRENT=$(cat "$VERSION_FILE")
    if [ "$CURRENT" = "$LATEST" ]; then
      echo "Up to date ($CURRENT)"
    else
      echo "Update available: $CURRENT → $LATEST"
      echo "Run \`denv/update.sh\` to update, then rebuild with \`docker build denv/ -t \$(basename \"\$PWD\")-denv --pull\`."
    fi
  else
    echo "Version unknown (no .trame-tools-version file). Run \`denv/update.sh\` to install latest ($LATEST)."
  fi
  exit 0
fi

# Default: update to specified or latest version
VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(get_latest_version)
fi

BASE="https://raw.githubusercontent.com/$REPO/$VERSION/tools"

curl -fsSL "$BASE/mcp.sh" -o "$SCRIPT_DIR/mcp.sh"
chmod +x "$SCRIPT_DIR/mcp.sh"

curl -fsSL "$BASE/AGENTS.md" -o "$SCRIPT_DIR/AGENTS.md"

echo "$VERSION" > "$VERSION_FILE"

echo "Updated to $REPO@$VERSION"
