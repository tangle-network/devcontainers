FROM base-system:latest

USER root
RUN npm install -g axios graphql-request viem ethers @evmexplorer/blockscout @blockscout/app-sdk @blockscout/ui-toolkit blockscout-typescript blockscout-cli hardhat @nomicfoundation/hardhat-toolbox
USER project

# Pre-warm npm cache with project-specific packages
RUN npm cache add @evmexplorer/blockscout@latest @blockscout/app-sdk@latest @blockscout/ui-toolkit@latest blockscout-typescript@latest blockscout-cli@latest graphql-request@latest || true

LABEL description="blockscout infrastructure layer"
