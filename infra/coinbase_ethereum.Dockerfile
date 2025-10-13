FROM base-system:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk ethers viem @wagmi/core
USER project

LABEL description="Combined: coinbase, ethereum"
