FROM base-system:latest

USER root
RUN npm install -g @injectivelabs/sdk-ts @injectivelabs/networks
USER project

LABEL description="injective infrastructure layer"
