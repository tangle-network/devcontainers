FROM foundry:latest

USER root
RUN npm install -g @consensys/linea-sdk ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER project

LABEL description="linea infrastructure layer"
