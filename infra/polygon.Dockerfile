FROM foundry:latest

USER root
RUN npm install -g ethers viem hardhat
USER project

LABEL description="polygon infrastructure layer"
