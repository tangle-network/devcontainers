FROM rust:latest

RUN cargo install solana-sdk

RUN cargo install anchor-lang

LABEL description="solana infrastructure layer"
