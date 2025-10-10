FROM nodejs:latest

RUN npm install -g @injectivelabs/sdk-ts @injectivelabs/networks

LABEL description="injective infrastructure layer"
