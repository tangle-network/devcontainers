FROM foundry:latest

USER root
RUN npm install -g @chainlink/contracts @chainlink/functions-toolkit @chainlink/local ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER agent

LABEL description="chainlink infrastructure layer"
