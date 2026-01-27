FROM foundry:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk ethers viem @wagmi/core
USER agent

LABEL description="Combined: coinbase, ethereum"
