FROM node:25-trixie-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/cargo/bin:/usr/local/share/pnpm:/usr/local/bin:${PATH}" \
    PNPM_HOME=/usr/local/share/pnpm \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo

# Install system dependencies + gosu for entrypoint user switching
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

# Install newer git (>= 2.48) from source for --relative-paths support
RUN cd /tmp \
    && curl -sL https://github.com/git/git/archive/refs/tags/v2.48.1.tar.gz | tar xz \
    && cd git-2.48.1 \
    && make -j$(nproc) prefix=/usr all \
    && make prefix=/usr install \
    && cd / && rm -rf /tmp/git-2.48.1

# Install pnpm via standalone script to system location
RUN curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" bash -

# Install just via pre-built binary
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install opencode from github releases
RUN cd /tmp \
    && curl -sL https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-x64.tar.gz | tar xz \
    && mv opencode /usr/local/bin \
    && rm -rf /tmp/opencode-linux-x64.tar.gz

# Install Rust toolchain to system location
RUN curl -sSf https://sh.rustup.rs --output rustup-init && \
    sh rustup-init -y --default-toolchain stable && \
    rm rustup-init && \
    rustup component add rustfmt clippy

# Entrypoint: create a user matching the host UID/GID, then drop privileges
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create a working directory
WORKDIR /workspace

# Set up volume for workspace
VOLUME /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
