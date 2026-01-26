FROM foundry:latest

USER root
RUN npm install -g @lifi/sdk @lifi/types @lifi/wallet-management ethers viem hardhat
USER agent

LABEL description="lifi infrastructure layer"
