FROM base-system:latest

RUN npm install -g ethers viem @wagmi/core

LABEL description="ethereum infrastructure layer"
