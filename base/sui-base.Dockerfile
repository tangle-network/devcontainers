# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network

FROM ghcr.io/shinamicorp/sui:testnet-v1.53.1 AS sui-tools

# Specialized: Sui Tools
FROM ${REGISTRY}/rust-base:latest

COPY --from=sui-tools \
    /usr/local/bin/sui-node \
    /usr/local/bin/sui \
    /usr/local/bin/

WORKDIR /

LABEL description="Sui blockchain development tools"