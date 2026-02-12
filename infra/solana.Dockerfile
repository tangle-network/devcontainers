FROM rust:latest

ENV     SOLANA_HOME=/root/.local/share/solana \
    PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash || echo 'Solana installation may not support this architecture. Consider building from source.' && \
    if [ -f /root/.local/share/solana/install/active_release/bin/solana ]; then /root/.local/share/solana/install/active_release/bin/solana --version && chmod -R a+rx /root/.local/share/solana; else echo 'Solana CLI not installed - platform may not be supported'; fi

USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add @solana/web3.js@latest @coral-xyz/anchor@latest @solana/spl-token@latest @metaplex-foundation/js@latest @solana/wallet-adapter-base@latest @solana/wallet-adapter-react@latest || true
# Pre-warm cargo cache with project-specific crates
RUN mkdir -p /tmp/cargo-warm && \
    printf '[package]\nname = "warm"\nversion = "0.0.0"\nedition = "2021"\n\n[dependencies]\nsolana-program = "1"\nanchor-lang = "0.30"\nspl-token = "4"\n' > /tmp/cargo-warm/Cargo.toml && \
    mkdir -p /tmp/cargo-warm/src && echo 'fn main() {}' > /tmp/cargo-warm/src/main.rs && \
    cd /tmp/cargo-warm && cargo fetch && \
    rm -rf /tmp/cargo-warm

USER root
RUN chmod -R a+w $CARGO_HOME
USER agent

LABEL description="solana infrastructure layer"
