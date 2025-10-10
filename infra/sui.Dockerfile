FROM rust:latest

RUN cargo install sui-sdk

LABEL description="sui infrastructure layer"
