FROM base-system:latest

USER root
RUN npm install -g @injectivelabs/sdk-ts @injectivelabs/networks
USER agent

LABEL description="injective infrastructure layer"
