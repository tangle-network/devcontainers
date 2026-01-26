FROM foundry:latest

USER root
RUN npm install -g @safe-global/protocol-kit @safe-global/api-kit @safe-global/safe-core-sdk-types @gnosis.pm/zodiac @gnosis.pm/safe-deployments ethers viem hardhat
USER agent

LABEL description="gnosis infrastructure layer"
