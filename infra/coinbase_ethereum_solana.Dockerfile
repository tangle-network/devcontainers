FROM base-system:latest

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    SOLANA_HOME=/root/.local/share/solana \
    PATH=/root/.local/share/solana/install/active_release/bin:/usr/local/cargo/bin:$PATH

USER root

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME

# Install Node.js packages (Coinbase + Ethereum)
RUN npm install -g @coinbase/coinbase-sdk ethers viem @wagmi/core

# Install Solana CLI with all dependencies
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash || echo 'Solana installation may not support this architecture. Consider building from source.' \
    && if [ -f /root/.local/share/solana/install/active_release/bin/solana ]; then \
         /root/.local/share/solana/install/active_release/bin/solana --version && \
         chmod -R a+rx /root/.local/share/solana; \
       else \
         echo 'Solana CLI not installed - platform may not be supported'; \
       fi

USER agent

LABEL description="Combined: coinbase, ethereum, solana (custom)"

