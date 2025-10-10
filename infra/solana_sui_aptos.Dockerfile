FROM rust:latest

RUN cargo install solana-sdk

RUN cargo install anchor-lang

RUN cargo install sui-sdk

RUN cargo install aptos-sdk

LABEL description="Combined: solana, sui, aptos"
