FROM rust:latest

RUN cargo install tangle-sdk

LABEL description="tangle infrastructure layer"
