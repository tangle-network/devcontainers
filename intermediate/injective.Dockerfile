# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/rust-base:latest

USER root

ARG INJECTIVE_VERSION=v1.13.3

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wget unzip && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        INJECTIVE_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        INJECTIVE_ARCH="arm64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    wget -q "https://github.com/InjectiveLabs/injective-chain-releases/releases/download/${INJECTIVE_VERSION}/linux-${INJECTIVE_ARCH}.zip" -O /tmp/injective.zip && \
    unzip -q /tmp/injective.zip -d /tmp/injective && \
    mv /tmp/injective/injectived /usr/local/bin/ && \
    mv /tmp/injective/peggo /usr/local/bin/ || true && \
    chmod +x /usr/local/bin/injectived && \
    rm -rf /tmp/injective.zip /tmp/injective

RUN npm install -g @injectivelabs/sdk-ts

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo new --lib injective-builder && \
    cd injective-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "injective-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'injective-std = "0.1"' >> Cargo.toml && \
    echo 'cosmwasm-std = "1"' >> Cargo.toml && \
    echo 'cosmwasm-schema = "1"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some deps may not build" && \
    cd .. && \
    rm -rf injective-builder

WORKDIR /workspace

USER rust

LABEL description="Injective Protocol development environment"

