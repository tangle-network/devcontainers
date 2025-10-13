FROM base-system:latest

USER root
RUN npm install -g zksync-ethers ethers zksync-cli
USER project

LABEL description="zksync infrastructure layer"
