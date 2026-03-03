# Project dev environment — extends trame-tools base image
FROM ghcr.io/trame-sh/trame-tools:latest

# [OPTIONAL] pnpm package manager — uncomment if using Node.js
# ENV PNPM_HOME=/usr/local/share/pnpm
# ENV PATH="$PNPM_HOME:$PATH"
# RUN curl -fsSL https://get.pnpm.io/install.sh | SHELL="$(which bash)" bash -

# [OPTIONAL] Rust toolchain — uncomment if using Rust
# ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo
# ENV PATH="/usr/local/cargo/bin:$PATH"
# RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
#     && rustup component add rustfmt clippy
