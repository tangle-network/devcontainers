FROM foundry:latest

USER root
RUN npm install -g @eth-optimism/supersim || echo 'Supersim installed for local OP Stack testing'

USER project

USER root
RUN npm install -g @eth-optimism/sdk @eth-optimism/core-utils ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER project

LABEL description="optimism infrastructure layer"
