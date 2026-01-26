FROM foundry:latest

ENV     PATH=/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    echo 'Brevis ZK coprocessor development environment ready'

USER agent

USER root
RUN npm install -g ethers viem hardhat
USER agent

LABEL description="brevis infrastructure layer"
