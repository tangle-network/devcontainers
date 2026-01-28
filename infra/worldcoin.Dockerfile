FROM foundry:latest

# Worldcoin World ID SDK
# IDKit, MiniKit, and on-chain verification support

USER root

# Install core Worldcoin packages globally
RUN npm install -g \
    @worldcoin/idkit \
    @worldcoin/minikit-js \
    viem \
    ethers

# Pre-warm npm cache with Worldcoin ecosystem packages
RUN npm cache add \
    @worldcoin/idkit@latest \
    @worldcoin/idkit-standalone@latest \
    @worldcoin/minikit-js@latest \
    @worldcoin/minikit-react@latest \
    # Common dependencies for World ID apps
    @simplewebauthn/browser@latest \
    @simplewebauthn/server@latest \
    # Frontend frameworks often used with IDKit
    next@latest \
    react@latest \
    react-dom@latest || true

USER agent

LABEL description="Worldcoin World ID SDK with IDKit and MiniKit for proof of personhood"
