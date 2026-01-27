FROM rust:latest

# Tangle v2 - no substrate dependencies required
# blueprint-sdk v2 is substrate-free

USER root

# Install cargo-tangle CLI from v2 branch
RUN cargo install --git https://github.com/tangle-network/blueprint-sdk --branch v2 cargo-tangle

USER agent

LABEL description="tangle infrastructure layer (v2, substrate-free)"
