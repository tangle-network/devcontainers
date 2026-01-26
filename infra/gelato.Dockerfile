FROM foundry:latest

USER root
RUN npm install -g @gelatonetwork/automate-sdk @gelatonetwork/relay-sdk @gelatonetwork/web3-functions-sdk ethers viem hardhat
USER agent

LABEL description="gelato infrastructure layer"
