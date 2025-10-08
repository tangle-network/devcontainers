# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/solana-base:latest

USER root

RUN npm install -g \
    @solana/web3.js \
    @coral-xyz/anchor \
    @metaplex-foundation/js

USER rust

WORKDIR /workspace

LABEL description="Solana development environment with additional libraries"

