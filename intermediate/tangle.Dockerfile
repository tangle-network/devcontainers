# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/rust-base:latest

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @polkadot/api @polkadot/util @polkadot/util-crypto

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo install subxt-cli --locked

RUN cargo new --lib tangle-builder && \
    cd tangle-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "tangle-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'subxt = "0.38"' >> Cargo.toml && \
    echo 'sp-core = "37"' >> Cargo.toml && \
    echo 'sp-runtime = "39"' >> Cargo.toml && \
    echo 'sp-keyring = "39"' >> Cargo.toml && \
    echo 'frame-support = "37"' >> Cargo.toml && \
    echo 'pallet-balances = "37"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some deps may not build" && \
    rm -rf /tangle-builder

WORKDIR /workspace

USER rust

LABEL description="Tangle Network development environment with Substrate tools"

