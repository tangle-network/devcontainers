FROM foundry:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk @coinbase/onchainkit @coinbase/wallet-sdk @coinbase/cdp-sdk @coinbase/agentkit viem wagmi permissionless localtunnel ethers @wagmi/core hardhat @nomicfoundation/hardhat-toolbox && chown -R agent:agent /tmp/.npm-cache 2>/dev/null || true
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add @coinbase/onchainkit@latest @coinbase/wallet-sdk@latest @coinbase/cdp-sdk@latest @coinbase/agentkit@latest @x402/fetch@latest @x402/axios@latest @x402/express@latest next@latest react@latest react-dom@latest typescript@latest tailwindcss@latest postcss@latest autoprefixer@latest @types/react@latest @types/react-dom@latest @types/node@latest @openzeppelin/contracts@latest @openzeppelin/contracts-upgradeable@latest wagmi@latest @rainbow-me/rainbowkit@latest abitype@latest || true

LABEL description="Combined: coinbase, ethereum"
