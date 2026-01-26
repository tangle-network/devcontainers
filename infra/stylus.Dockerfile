FROM foundry:latest

USER root
RUN rustup target add wasm32-unknown-unknown

USER agent

RUN cargo install cargo-stylus

LABEL description="stylus infrastructure layer"
