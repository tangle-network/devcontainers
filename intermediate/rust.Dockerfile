FROM base-system:latest

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

USER root
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Pre-warm cargo cache with commonly used crates
RUN mkdir -p /tmp/cargo-warm && \
    printf '[package]\nname = "warm"\nversion = "0.0.0"\nedition = "2021"\n\n[dependencies]\ntokio = { version = "1", features = ["full"] }\nserde = { version = "1", features = ["derive"] }\nserde_json = "1"\nthiserror = "1"\nanyhow = "1"\ntracing = "0.1"\ntracing-subscriber = "0.3"\nasync-trait = "0.1"\nfutures = "0.3"\nreqwest = { version = "0.12", features = ["json"] }\nclap = { version = "4", features = ["derive"] }\n' > /tmp/cargo-warm/Cargo.toml && \
    mkdir -p /tmp/cargo-warm/src && \
    echo 'fn main() {}' > /tmp/cargo-warm/src/main.rs && \
    cd /tmp/cargo-warm && cargo fetch && \
    rm -rf /tmp/cargo-warm && \
    chmod -R a+w $CARGO_HOME

# Install rust-analyzer LSP for Rust code intelligence
RUN rustup component add rust-analyzer && \
    ln -sf $(rustup which --toolchain stable rust-analyzer) /usr/local/bin/rust-analyzer

USER project

LABEL description="Rust intermediate layer"
