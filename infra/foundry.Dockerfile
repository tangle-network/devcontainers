FROM foundry:latest

USER root
RUN npm install -g ethers viem hardhat @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-foundry
USER agent

LABEL description="foundry infrastructure layer"
