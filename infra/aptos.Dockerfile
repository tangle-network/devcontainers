FROM rust:latest

ENV     PATH=/root/.local/bin:/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      python3-pip && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN cargo install --git https://github.com/aptos-labs/aptos-core.git aptos --locked && \
    aptos --version || echo 'Aptos CLI installed'

USER project

LABEL description="aptos infrastructure layer"
