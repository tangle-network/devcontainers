FROM rust:latest

ENV     PATH=/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN cargo install --git https://github.com/paradigmxyz/reth.git --locked reth && \
    reth --version

USER project

LABEL description="reth infrastructure layer"
