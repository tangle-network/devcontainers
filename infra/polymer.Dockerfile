FROM foundry:latest

USER root
RUN npm install -g @open-ibc/vibc-core-smart-contracts ethers viem hardhat
USER project

LABEL description="polymer infrastructure layer"
