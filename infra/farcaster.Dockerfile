FROM foundry:latest

USER root
RUN npm install -g frames.js @farcaster/hub-nodejs @farcaster/core @coinbase/onchainkit viem wagmi hono next

# Pre-warm npm cache with project-specific packages (run as root to avoid permission issues)
RUN npm cache add frames.js@latest @farcaster/hub-nodejs@latest @coinbase/onchainkit@latest frog@latest || true

USER agent

LABEL description="farcaster infrastructure layer"
