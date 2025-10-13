FROM base-system:latest

USER root
RUN npm install -g ethers viem
USER project

LABEL description="polygon infrastructure layer"
