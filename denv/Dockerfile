FROM node:20-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/root/.cargo/bin:/root/.local/bin:${PATH}"

# Install system dependencies + gosu for entrypoint user switching
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gnupg \
    ca-certificates \
    python3 \
    python3-pip \
    build-essential \
    gosu \
    && rm -rf /var/lib/apt/lists/*

RUN npm i -g opencode-ai
RUN npm i -g pnpm@latest-10
RUN npm install -g rust-just

# Install Rust toolchain (into /root; entrypoint copies it to the dynamic user)
RUN curl -sSf https://sh.rustup.rs --output rustup-init && \
    sh rustup-init -y && \
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
