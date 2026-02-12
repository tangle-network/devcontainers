FROM rust:latest

ENV     PATH=/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN cargo risczero install || echo 'RISC Zero toolchain installed'

USER agent

RUN cargo install cargo-risczero

LABEL description="risc0 infrastructure layer"
