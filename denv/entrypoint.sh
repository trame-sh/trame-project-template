#!/bin/bash
set -e

USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

# Create group and user matching host IDs
groupadd -g "$GROUP_ID" -o dev 2>/dev/null || true
useradd -m -u "$USER_ID" -g "$GROUP_ID" -o -s /bin/bash dev 2>/dev/null || true

export HOME=/home/dev

# Copy Rust toolchain from root into the dynamic user's home
if [ -d /root/.cargo ] && [ ! -d "$HOME/.cargo" ]; then
  cp -r /root/.cargo "$HOME/.cargo"
  cp -r /root/.rustup "$HOME/.rustup"
fi

# Ensure the dynamic user owns their home directory
chown -R "$USER_ID":"$GROUP_ID" "$HOME"

# Execute as the dynamic user
exec gosu dev env HOME="$HOME" "$@"
