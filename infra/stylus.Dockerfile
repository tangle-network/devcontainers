FROM foundry:latest

USER root
RUN rustup target add wasm32-unknown-unknown

USER project

RUN cargo install cargo-stylus

LABEL description="stylus infrastructure layer"
