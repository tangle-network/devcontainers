FROM foundry:latest

USER root
RUN npm install -g @openzeppelin/contracts @openzeppelin/contracts-upgradeable @openzeppelin/upgrades-core @openzeppelin/defender-sdk @openzeppelin/hardhat-upgrades @openzeppelin/wizard hardhat ethers
USER agent

LABEL description="openzeppelin infrastructure layer"
