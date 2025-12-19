FROM rust:latest

# APT packages (as root)
USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      libssl-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*
USER project

# Root commands (curl | bash installers, etc.)
USER root
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tangle-network/blueprint/releases/download/cargo-tangle/v0.1.1-beta.7/cargo-tangle-installer.sh | sh
USER project

# Cargo packages (as user)
RUN cargo install cargo-tangle

LABEL description="tangle-blueprint-sdk-rust infrastructure layer"
