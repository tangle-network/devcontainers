# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network# Keep up-to-date with https://github.com/anza-xyz/agave/blob/master/rust-toolchain.toml
FROM rust:1.86.0-slim-bookworm AS builder-base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pkg-config \
        libssl-dev \
        libudev-dev \
        llvm \
        libclang-dev \
        protobuf-compiler \
        curl \
        && \
    rm -rf /var/lib/apt/lists/*

FROM builder-base AS solana-builder

WORKDIR /usr/src/agave

# Shallow clone of a specific commit for Solana CLI
ARG AGAVE_GIT_REF=v2.2.15
RUN git init && \
    git remote add origin https://github.com/anza-xyz/agave.git && \
    git fetch --depth 1 origin ${AGAVE_GIT_REF} && \
    git checkout FETCH_HEAD

# Use the official build script as per installation instructions
RUN ./scripts/cargo-install-all.sh .

FROM builder-base AS anchor-builder

WORKDIR /usr/src/anchor

# Shallow clone of a specific commit for Anchor CLI
ARG ANCHOR_GIT_REF=v0.31.1
RUN git init && \
    git remote add origin https://github.com/coral-xyz/anchor.git && \
    git fetch --depth 1 origin ${ANCHOR_GIT_REF} && \
    git checkout FETCH_HEAD

RUN cargo build --locked --release --bin anchor

# Specialized: Solana/Anchor Tools
FROM ${REGISTRY}/rust-base:latest

# Copy all Solana binaries directly from builder
COPY --from=solana-builder /usr/src/agave/bin/ /usr/local/bin/

# Copy Anchor binary
COPY --from=anchor-builder /usr/src/anchor/target/release/anchor /usr/local/bin/

RUN cargo new --lib solana-builder && \
    cd solana-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "solana-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'solana-sdk = "1.18"' >> Cargo.toml && \
    echo 'solana-program = "1.18"' >> Cargo.toml && \
    echo 'anchor-lang = "0.29"' >> Cargo.toml && \
    echo 'spl-token = "4"' >> Cargo.toml && \
    echo 'borsh = "0.10"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some Solana deps may not build" && \
    rm -rf /solana-builder || true

# Download all toolchains
RUN anchor init temp-project --no-git --no-install && \
    cd temp-project && \
    cargo-build-sbf --force-tools-install
RUN chmod a+w /usr/local/bin/platform-tools-sdk/sbf/dependencies

WORKDIR /

# Expose ports for Solana validator
EXPOSE 8899
EXPOSE 8900
EXPOSE 9900

LABEL description="Solana and Anchor Framework tools"