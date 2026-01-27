FROM base-system:latest

USER root
RUN npm install -g @xmtp/xmtp-js @xmtp/react-sdk @xmtp/content-type-text @xmtp/content-type-reaction @xmtp/content-type-reply @xmtp/content-type-remote-attachment viem ethers

# Pre-warm npm cache with project-specific packages (non-fatal if packages unavailable, run as root)
RUN npm cache add @xmtp/xmtp-js@latest @xmtp/react-sdk@latest @xmtp/mls-client@latest || true

USER agent

LABEL description="xmtp infrastructure layer"
