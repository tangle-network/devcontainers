FROM rust:latest

USER root
RUN npm install -g @tangle-network/tangle-substrate-types
USER agent

RUN cargo install subxt-cli --version 0.39.0

# Pre-warm cargo cache with project-specific crates
RUN mkdir -p /tmp/cargo-warm && \
    printf '[package]\nname = "warm"\nversion = "0.0.0"\nedition = "2021"\n\n[dependencies]\nsubxt = "0.39"\nsp-core = "*"\nsp-runtime = "*"\nframe-support = "*"\n' > /tmp/cargo-warm/Cargo.toml && \
    mkdir -p /tmp/cargo-warm/src && echo 'fn main() {}' > /tmp/cargo-warm/src/main.rs && \
    cd /tmp/cargo-warm && cargo fetch && \
    rm -rf /tmp/cargo-warm && \
    chmod -R a+w $CARGO_HOME

LABEL description="tangle infrastructure layer"
