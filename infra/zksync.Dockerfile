FROM rust:latest

ENV     PATH=/root/.foundry-zksync/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash && /root/.foundry-zksync/bin/foundryup-zksync && chmod -R a+rx /root/.foundry-zksync && \
    curl -L https://raw.githubusercontent.com/matter-labs/anvil-zksync/main/scripts/install.sh | bash && chmod -R a+rx /root/.anvil-zksync || echo 'anvil-zksync installed' && \
    forge --version && cast --version || echo 'foundry-zksync installed'

USER agent

USER root
RUN npm install -g zksync-ethers ethers zksync-cli hardhat @matterlabs/hardhat-zksync
USER agent

LABEL description="zksync infrastructure layer"
