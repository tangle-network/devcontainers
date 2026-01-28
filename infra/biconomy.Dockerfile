FROM foundry:latest

# Biconomy Account Abstraction SDK
# Smart accounts, bundlers, paymasters, and session keys

USER root

# Install core Biconomy packages globally
RUN npm install -g \
    @biconomy/account \
    @biconomy/bundler \
    @biconomy/paymaster \
    @biconomy/modules \
    @biconomy/common \
    permissionless \
    viem \
    ethers

# Pre-warm npm cache with Biconomy ecosystem packages (run as root to avoid permission issues)
RUN npm cache add \
    @biconomy/account@latest \
    @biconomy/bundler@latest \
    @biconomy/paymaster@latest \
    @biconomy/modules@latest \
    @biconomy/common@latest \
    @biconomy/particle-auth@latest \
    permissionless@latest \
    @pimlico/alto@latest \
    userop@latest \
    @account-abstraction/sdk@latest \
    @account-abstraction/contracts@latest || true

USER agent

LABEL description="Biconomy Account Abstraction SDK with smart accounts, bundlers, and paymasters"
