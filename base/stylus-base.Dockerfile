# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM offchainlabs/nitro-node:v3.7.0-rc.7-efa52d5-slim AS nitro-node-stylus-dev

# Specialized: Arbitrum Stylus Tools
FROM ${REGISTRY}/ethereum-base:latest

# Copy all nitro-node binaries from the nitro-node-stylus-dev stage
COPY --from=nitro-node-stylus-dev /usr/local/bin/* /usr/local/bin/

# Prepare product-ready rust toolchain following the cargo-stylus
RUN rustup default 1.87.0 && \
    rustup target add wasm32-unknown-unknown

# Install Stylus CLI for Arbitrum with error handling
# Install Stylus tools with cache mount for faster rebuilds
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo install cargo-stylus cargo-stylus-check --force --locked

RUN cargo new --lib stylus-builder && \
    cd stylus-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "stylus-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'stylus-sdk = "0.5"' >> Cargo.toml && \
    echo 'alloy-primitives = "0.7"' >> Cargo.toml && \
    echo 'alloy-sol-types = "0.7"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some deps may not build" && \
    rm -rf /cache-builder || true

LABEL description="Arbitrum Stylus development tools with Ethereum base"