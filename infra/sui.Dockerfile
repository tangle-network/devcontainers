FROM rust:latest

ENV     PATH=/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN cargo install --locked --git https://github.com/MystenLabs/sui.git --branch mainnet sui

USER agent

LABEL description="sui infrastructure layer"
