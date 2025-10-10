FROM nodejs:latest

RUN npm install -g @coinbase/coinbase-sdk mongodb

LABEL description="Combined: coinbase, mongodb"
