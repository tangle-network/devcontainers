FROM rust:latest

RUN cargo install cargo-stylus

LABEL description="stylus infrastructure layer"
