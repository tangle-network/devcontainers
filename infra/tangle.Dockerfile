FROM rust:latest

USER root
RUN npm install -g @tangle-network/tangle-substrate-types
USER project

RUN cargo install subxt-cli --version 0.39.0

LABEL description="tangle infrastructure layer"
