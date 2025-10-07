# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network# Specialized: Noir ZK Tools
FROM ${REGISTRY}/ethereum-base:latest

ENV PATH="/usr/local/bin/nargo/bin:/usr/local/bin/bb/:$PATH"

# Install Noir (nargo)
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/tags/v0.1.4/install | bash && \
    /root/.nargo/bin/noirup --version 1.0.0-beta.6 && \
    mkdir -p /usr/local/bin/nargo/ && \
    mv /root/.nargo/* /usr/local/bin/nargo

# Install Noir Backend Barretenberg
RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash && \
    /root/.bb/bbup --noir-version 1.0.0-beta.6 && \
    mkdir -p /usr/local/bin/bb/ && \
    mv /root/.bb/* /usr/local/bin/bb/

WORKDIR /

LABEL description="Noir zero-knowledge proof language tools"
