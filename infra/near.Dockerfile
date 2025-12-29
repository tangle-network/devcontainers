FROM rust:latest

ENV     PATH=/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN cargo install cargo-near && \
    rustup target add wasm32-unknown-unknown && \
    cargo near --version || echo 'cargo-near installed'

USER project

USER root
RUN npm install -g near-cli near-api-js @near-js/client near-seed-phrase
USER project

LABEL description="near infrastructure layer"
