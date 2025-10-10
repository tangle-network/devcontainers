FROM rust:latest

RUN cargo install risc0-zkvm

LABEL description="risc0 infrastructure layer"
