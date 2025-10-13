FROM rust:latest

ENV     SOLANA_HOME=/root/.local/share/solana \
    PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash || echo 'Solana installation may not support this architecture. Consider building from source.' && \
    if [ -f /root/.local/share/solana/install/active_release/bin/solana ]; then /root/.local/share/solana/install/active_release/bin/solana --version && chmod -R a+rx /root/.local/share/solana; else echo 'Solana CLI not installed - platform may not be supported'; fi

USER project

LABEL description="solana infrastructure layer"
