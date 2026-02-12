FROM foundry:latest

USER root
RUN npm install -g viem ethers wagmi @wagmi/core @eth-optimism/sdk @eth-optimism/core-utils @eth-optimism/common-ts @eth-optimism/contracts-bedrock @okxweb3/connect-kit @okxweb3/coin-ethereum @okxweb3/coin-base @okxweb3/crypto-lib @okxweb3/hardhat-explorer-verify @okxweb3/dex-widget @maticnetwork/maticjs @maticnetwork/maticjs-ethers @maticnetwork/maticjs-web3 @maticnetwork/fx-portal hardhat @nomicfoundation/hardhat-toolbox
USER project

# Pre-warm npm cache with project-specific packages
RUN npm cache add @okxweb3/connect-kit@latest @okxweb3/coin-ethereum@latest @okxweb3/coin-base@latest @okxweb3/crypto-lib@latest @eth-optimism/sdk@latest @eth-optimism/core-utils@latest @eth-optimism/contracts-bedrock@latest viem@latest wagmi@latest

LABEL description="xlayer infrastructure layer"
