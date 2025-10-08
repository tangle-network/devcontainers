# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/ethereum-base:latest

USER root

RUN git clone https://github.com/brevis-network/brevis-sdk.git /tmp/brevis-sdk && \
    cd /tmp/brevis-sdk && \
    npm install -g . && \
    cd / && \
    rm -rf /tmp/brevis-sdk

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo new --lib brevis-builder && \
    cd brevis-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "brevis-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'halo2-base = "0.4"' >> Cargo.toml && \
    echo 'halo2-ecc = "0.4"' >> Cargo.toml && \
    echo 'snark-verifier = "0.1"' >> Cargo.toml && \
    cargo build --release 2>/dev/null || echo "Some deps may not build" && \
    cd .. && \
    rm -rf brevis-builder

WORKDIR /workspace

LABEL description="Brevis zkVM coprocessor development environment"

