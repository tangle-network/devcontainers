FROM base-system:latest

RUN npm install -g ethers viem @wagmi/core @polygon-labs/sdk zksync-ethers

LABEL description="Combined: ethereum, polygon, zksync"
