# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/rust-base:latest

USER root

ARG APTOS_CLI_VERSION=4.9.1

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wget unzip && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        APTOS_ARCH="Ubuntu-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        APTOS_ARCH="Ubuntu-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    wget -q "https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v${APTOS_CLI_VERSION}/aptos-cli-${APTOS_CLI_VERSION}-${APTOS_ARCH}.zip" -O /tmp/aptos.zip && \
    unzip -q /tmp/aptos.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/aptos && \
    rm /tmp/aptos.zip

RUN npm install -g @aptos-labs/ts-sdk

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo new --lib aptos-builder && \
    cd aptos-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "aptos-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'aptos-sdk = "0.3"' >> Cargo.toml && \
    echo 'move-core-types = "0.0.7"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some deps may not build" && \
    cd .. && \
    rm -rf aptos-builder

WORKDIR /workspace

USER rust

LABEL description="Aptos blockchain development environment"

