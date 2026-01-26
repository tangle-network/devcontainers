FROM foundry:latest

USER root
RUN npm install -g ethers viem hardhat
USER agent

LABEL description="polygon infrastructure layer"
