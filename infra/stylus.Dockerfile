FROM foundry:latest

USER root
RUN rustup target add wasm32-unknown-unknown && \
    cargo install cargo-stylus && \
    chmod -R a+w /usr/local/cargo

USER agent

LABEL description="stylus infrastructure layer"
