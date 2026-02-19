FROM rust:latest

USER root
RUN npm install -g @tangle-network/tangle-substrate-types

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends protobuf-compiler libprotobuf-dev && \
    rm -rf /var/lib/apt/lists/*

ENV PROTOC=/usr/bin/protoc \
    PROTOC_INCLUDE=/usr/include

ARG CARGO_TANGLE_VERSION=0.4.0-alpha.22
RUN cargo install --locked cargo-tangle --version ${CARGO_TANGLE_VERSION}

# Pre-warm cargo cache with project-specific crates
RUN mkdir -p /tmp/cargo-warm && \
    printf '[package]\nname = "warm"\nversion = "0.0.0"\nedition = "2021"\n\n[dependencies]\nsp-core = "*"\nsp-runtime = "*"\nframe-support = "*"\n' > /tmp/cargo-warm/Cargo.toml && \
    mkdir -p /tmp/cargo-warm/src && echo 'fn main() {}' > /tmp/cargo-warm/src/main.rs && \
    cd /tmp/cargo-warm && cargo fetch && \
    rm -rf /tmp/cargo-warm

USER agent

LABEL description="tangle infrastructure layer"
