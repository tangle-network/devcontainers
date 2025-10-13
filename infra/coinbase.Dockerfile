FROM base-system:latest

USER root
RUN npm install -g @coinbase/coinbase-sdk
USER project

LABEL description="coinbase infrastructure layer"
