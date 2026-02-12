FROM foundry:latest

USER root
RUN npm install -g ethers viem @wagmi/core hardhat @nomicfoundation/hardhat-toolbox
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add @openzeppelin/contracts@latest @openzeppelin/contracts-upgradeable@latest wagmi@latest @rainbow-me/rainbowkit@latest abitype@latest || true

LABEL description="ethereum infrastructure layer"
