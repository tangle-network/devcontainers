FROM base-system:latest

USER root
RUN npm install -g prettier
USER project

LABEL description="prettier intermediate layer"
