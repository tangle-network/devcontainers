FROM rust:latest

ENV PATH=/root/.risc0/bin:/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN cargo install cargo-risczero && \
    cargo risczero install || echo 'RISC Zero toolchain installed'

USER project

LABEL description="risc0 infrastructure layer"
