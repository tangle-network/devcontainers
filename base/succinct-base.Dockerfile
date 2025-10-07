# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network# Specialized: SP1/Succinct Tools
FROM ${REGISTRY}/ethereum-base:latest

ENV CARGO_HOME="/usr/local/cargo"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV PATH="/usr/local/cargo/bin:${PATH}"

# Build sp1 binaries from source with cache mount for faster rebuilds
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/tmp/sp1-cache \
    cd /tmp && \
    rm -rf sp1-build && \
    git clone https://github.com/succinctlabs/sp1 sp1-build && \
    cd sp1-build/crates/cli && \
    # Link the cache directory as target for cargo to use \
    ln -s /tmp/sp1-cache target && \
    RUST_BACKTRACE=1 cargo install --locked --force --path . && \
    cd / && \
    rm -rf /tmp/sp1-build

# Install SP1 toolchain with cache mount
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    RUST_BACKTRACE=1 cargo prove install-toolchain

WORKDIR /

LABEL description="SP1 Succinct proof system with Ethereum tools"
