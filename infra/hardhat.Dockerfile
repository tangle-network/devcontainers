FROM foundry:latest

USER root
RUN npm install -g hardhat @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-verify ethers viem
USER project

LABEL description="hardhat infrastructure layer"
