FROM nodejs:latest

RUN npm install -g ethers viem @polygon-labs/sdk

LABEL description="polygon infrastructure layer"
