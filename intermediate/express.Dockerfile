FROM base-system:latest

USER root
RUN npm install -g express @types/express express-generator
USER project

LABEL description="express intermediate layer"
