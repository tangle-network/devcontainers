FROM foundry:latest

USER root
RUN npm install -g @arbitrum/sdk ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER project

LABEL description="arbitrum infrastructure layer"
