FROM foundry:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk @coinbase/onchainkit @coinbase/wallet-sdk @coinbase/cdp-sdk @coinbase/agentkit viem wagmi permissionless localtunnel
USER project

# Pre-warm npm cache with project-specific packages
RUN npm cache add @coinbase/onchainkit@latest @coinbase/wallet-sdk@latest @coinbase/cdp-sdk@latest @coinbase/agentkit@latest @x402/fetch@latest @x402/axios@latest @x402/express@latest

LABEL description="coinbase infrastructure layer"
