#!/usr/bin/env bash
# Bootstrap: fetch the real update.sh from trame-tools and exec it.
# After first run, this file is replaced by the self-updating version.
set -euo pipefail

REPO="trame-sh/trame-tools"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
fi

curl -fsSL "https://raw.githubusercontent.com/$REPO/$VERSION/tools/update.sh" -o "$SCRIPT_DIR/update.sh"
chmod +x "$SCRIPT_DIR/update.sh"
exec "$SCRIPT_DIR/update.sh" "$VERSION"
