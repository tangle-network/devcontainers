FROM base-system:latest

USER root
RUN npm install -g hardhat ethers @nomicfoundation/hardhat-toolbox
USER project

LABEL description="hardhat infrastructure layer"
