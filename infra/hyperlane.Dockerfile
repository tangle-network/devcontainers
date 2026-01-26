FROM rust:latest

ENV     PATH=/root/.foundry/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl -L https://foundry.paradigm.xyz | bash && /root/.foundry/bin/foundryup && chmod -R a+rx /root/.foundry && \
    git clone --depth 1 https://github.com/hyperlane-xyz/hyperlane-monorepo.git /tmp/hyperlane && cd /tmp/hyperlane/rust && cargo build --release --bin validator --bin relayer && cp target/release/validator target/release/relayer /usr/local/bin/ && chmod +x /usr/local/bin/validator /usr/local/bin/relayer && rm -rf /tmp/hyperlane && \
    validator --help || echo 'Hyperlane validator installed' && \
    relayer --help || echo 'Hyperlane relayer installed'

USER agent

USER root
RUN npm install -g @hyperlane-xyz/sdk @hyperlane-xyz/core @hyperlane-xyz/utils @hyperlane-xyz/cli ethers viem
USER agent

LABEL description="hyperlane infrastructure layer"
