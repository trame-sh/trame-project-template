#!/bin/bash
set -e

USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

# Reuse the existing 'node' user from the base image.
# Update its UID/GID to match the host so file ownership is correct.
groupmod -g "$GROUP_ID" -o node 2>/dev/null || true
usermod -u "$USER_ID" -g "$GROUP_ID" -o node 2>/dev/null || true

export HOME=/home/node

# Ensure the user owns their home directory
chown -R "$USER_ID":"$GROUP_ID" "$HOME"

# Ensure the agent signals directory is writable
if [ -n "$AGENT_SIGNALS_DIR" ]; then
  mkdir -p "$AGENT_SIGNALS_DIR"
  chown "$USER_ID":"$GROUP_ID" "$AGENT_SIGNALS_DIR"
fi

# Execute as the node user
exec gosu node env HOME="$HOME" "$@"
