FROM foundry:latest

USER root
RUN npm install -g frames.js @farcaster/hub-nodejs @farcaster/core @coinbase/onchainkit viem wagmi hono next
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add frames.js@latest @farcaster/hub-nodejs@latest @coinbase/onchainkit@latest frog@latest || true

LABEL description="farcaster infrastructure layer"
