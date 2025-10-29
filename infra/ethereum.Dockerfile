FROM base-system:latest

USER root
RUN npm install -g ethers viem @wagmi/core
USER project

LABEL description="ethereum blueprint"
