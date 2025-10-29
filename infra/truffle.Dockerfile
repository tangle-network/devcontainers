FROM base-system:latest

USER root
RUN npm install -g truffle @truffle/hdwallet-provider
USER project

LABEL description="truffle blueprint"
