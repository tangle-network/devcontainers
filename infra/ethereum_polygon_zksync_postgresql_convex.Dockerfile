FROM nodejs:latest

RUN npm install -g ethers viem @wagmi/core @polygon-labs/sdk zksync-ethers pg @types/pg convex

LABEL description="Combined: ethereum, polygon, zksync, postgresql, convex"
