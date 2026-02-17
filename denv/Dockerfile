# [OPTIONAL: node] Base image — provides Node.js runtime and a 'node' user.
# Swap to a different base if project doesn't use Node (update entrypoint.sh user accordingly).
FROM node:25-trixie-slim

# [ADAPT] Environment variables — adjust PATH entries based on which optional layers you keep.
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/cargo/bin:/usr/local/share/pnpm:/usr/local/bin:${PATH}" \
    PNPM_HOME=/usr/local/share/pnpm \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo

# [REQUIRED] System dependencies + gosu for entrypoint user switching.
# The git build deps (libcurl4-gnutls-dev, libexpat1-dev, etc.) are also required.
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    python3 \
    python3-pip \
    build-essential \
    gosu \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
    libz-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# [REQUIRED] Git >= 2.48 from source — needed for --relative-paths worktree support.
RUN cd /tmp \
    && curl -sL https://github.com/git/git/archive/refs/tags/v2.48.1.tar.gz | tar xz \
    && cd git-2.48.1 \
    && make -j$(nproc) prefix=/usr all \
    && make prefix=/usr install \
    && cd / && rm -rf /tmp/git-2.48.1

# [OPTIONAL: node] pnpm package manager — remove if not using Node.js.
RUN curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" bash -

# [REQUIRED] just command runner — used by the agent loop and all recipes.
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# [AGENT-CLI] Install opencode. Replace this block when using a different agent CLI.
RUN cd /tmp \
    && curl -sL https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-x64.tar.gz | tar xz \
    && mv opencode /usr/local/bin \
    && rm -rf /tmp/opencode-linux-x64.tar.gz

# [OPTIONAL: rust] Rust toolchain — remove if project doesn't use Rust.
RUN curl -sSf https://sh.rustup.rs --output rustup-init && \
    sh rustup-init -y --default-toolchain stable && \
    rm rustup-init && \
    rustup component add rustfmt clippy

# [REQUIRED] Entrypoint: maps container UID/GID to host user, then drops privileges.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# [REQUIRED] Working directory and volume.
WORKDIR /workspace
VOLUME /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
