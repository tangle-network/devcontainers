FROM foundry:latest

USER root
RUN rustup target add wasm32-unknown-unknown && \
    cargo install cargo-stylus

USER agent

LABEL description="stylus infrastructure layer"
