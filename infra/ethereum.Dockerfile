FROM foundry:latest

USER root
RUN npm install -g ethers viem @wagmi/core hardhat @nomicfoundation/hardhat-toolbox
USER agent

LABEL description="ethereum infrastructure layer"
