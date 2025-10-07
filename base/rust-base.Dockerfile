# syntax=docker/dockerfile:1.4
# Layer 1: Rust Base - For services needing Rust
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/base-system:latest

# Install additional system dependencies for Rust development
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      software-properties-common gnupg ca-certificates sudo \
      libclang-dev clang llvm protobuf-compiler libprotobuf-dev \
      meson ninja-build libcap-dev libcap2-bin \
      libssl-dev pkg-config libudev-dev && \
    rm -rf /var/lib/apt/lists/*

# Create rust user and group for secure toolchain management
RUN groupadd --gid 1001 rust && \
    useradd --uid 1001 --gid rust --shell /bin/bash --create-home rust && \
    echo 'rust ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Rust toolchain with proper ownership
ENV RUSTUP_HOME="/usr/local/rustup"
ENV CARGO_HOME="/usr/local/cargo"
ENV PATH="/usr/local/cargo/bin:${PATH}"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    --default-toolchain stable \
    --profile default \
    --no-modify-path \
    -y && \
    chown -R rust:rust $RUSTUP_HOME $CARGO_HOME && \
    chmod -R 755 $RUSTUP_HOME $CARGO_HOME

# Install additional Rust components and tools (run as root for system-wide install)
RUN rustup component add rustfmt clippy rust-src && \
    rustup target add wasm32-unknown-unknown && \
    cargo install --locked \
      cargo-edit \
      cargo-watch \
      cargo-expand \
      sccache \
      wasm-pack && \
    chown -R rust:rust $RUSTUP_HOME $CARGO_HOME

# Set up sccache for faster compilation with secure permissions
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=/usr/local/cargo/.sccache
RUN mkdir -p $SCCACHE_DIR && \
    chown -R rust:rust $SCCACHE_DIR && \
    chmod -R 755 $SCCACHE_DIR

# Pre-compile common Rust dependencies for faster builds
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/usr/local/cargo/.sccache \
    mkdir -p /tmp/cache-builder && \
    cd /tmp/cache-builder && \
    cargo init --name cache-builder && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'tokio = { version = "1", features = ["full"] }' >> Cargo.toml && \
    echo 'async-trait = "0.1"' >> Cargo.toml && \
    echo 'futures = "0.3"' >> Cargo.toml && \
    echo 'serde = { version = "1", features = ["derive"] }' >> Cargo.toml && \
    echo 'serde_json = "1"' >> Cargo.toml && \
    echo 'toml = "0.8"' >> Cargo.toml && \
    echo 'axum = "0.7"' >> Cargo.toml && \
    echo 'reqwest = { version = "0.12", features = ["json", "rustls-tls"] }' >> Cargo.toml && \
    echo 'hyper = { version = "1", features = ["full"] }' >> Cargo.toml && \
    echo 'tower = "0.4"' >> Cargo.toml && \
    echo 'tower-http = { version = "0.5", features = ["full"] }' >> Cargo.toml && \
    echo 'anyhow = "1"' >> Cargo.toml && \
    echo 'thiserror = "1"' >> Cargo.toml && \
    echo 'clap = { version = "4", features = ["derive"] }' >> Cargo.toml && \
    echo 'tracing = "0.1"' >> Cargo.toml && \
    echo 'tracing-subscriber = { version = "0.3", features = ["env-filter"] }' >> Cargo.toml && \
    echo 'sha2 = "0.10"' >> Cargo.toml && \
    echo 'hex = "0.4"' >> Cargo.toml && \
    echo 'base64 = "0.22"' >> Cargo.toml && \
    echo 'uuid = { version = "1", features = ["v4", "serde"] }' >> Cargo.toml && \
    echo 'chrono = { version = "0.4", features = ["serde"] }' >> Cargo.toml && \
    echo 'regex = "1"' >> Cargo.toml && \
    echo 'mockall = "0.12"' >> Cargo.toml

# Build dependencies with optimized settings
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/usr/local/cargo/.sccache \
    cd /tmp/cache-builder && \
    CARGO_BUILD_JOBS=$(nproc 2>/dev/null || echo "4") \
    cargo build --release && \
    rm -rf /tmp/cache-builder && \
    chown -R rust:rust $RUSTUP_HOME $CARGO_HOME

# Verify installation
RUN cargo --version && \
    rustc --version && \
    rustup --version && \
    sccache --version

# Set up project workspace with proper permissions
RUN mkdir -p /workspace && \
    chown -R rust:rust /workspace

WORKDIR /workspace

# Switch to rust user for safer operations
USER rust

LABEL description="Rust toolchain with pre-compiled common dependencies and essential tools"