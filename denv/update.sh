#!/usr/bin/env bash
set -euo pipefail

REPO="trame-sh/trame-tools"
VERSION="${1:-latest}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
fi

BASE="https://raw.githubusercontent.com/$REPO/$VERSION/tools"

curl -fsSL "$BASE/mcp.sh" -o "$SCRIPT_DIR/mcp.sh"
chmod +x "$SCRIPT_DIR/mcp.sh"

curl -fsSL "$BASE/AGENTS.md" -o "$SCRIPT_DIR/AGENTS.md"

echo "Updated to $REPO@$VERSION"
