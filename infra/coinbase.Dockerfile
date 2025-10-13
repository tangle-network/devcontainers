FROM base-system:latest

RUN npm install -g @coinbase/coinbase-sdk

LABEL description="coinbase infrastructure layer"
