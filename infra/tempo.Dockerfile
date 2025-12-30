FROM foundry:latest

USER root
RUN npm install -g ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER project

LABEL description="tempo infrastructure layer"
