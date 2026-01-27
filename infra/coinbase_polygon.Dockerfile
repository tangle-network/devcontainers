FROM foundry:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk ethers viem
USER agent

LABEL description="Combined: coinbase, polygon"
