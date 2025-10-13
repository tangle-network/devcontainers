FROM base-system:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk ethers viem
USER project

LABEL description="Combined: coinbase, polygon"
