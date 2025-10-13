FROM rust:latest

USER root
RUN npm install -g @tangle-network/tangle-substrate-types
USER project

LABEL description="tangle infrastructure layer"
