FROM foundry:latest

USER root
RUN npm install -g ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER agent

LABEL description="monad infrastructure layer"
