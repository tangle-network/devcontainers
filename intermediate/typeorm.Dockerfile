FROM base-system:latest

USER root
RUN npm install -g typeorm @types/node reflect-metadata
USER project

LABEL description="typeorm intermediate layer"
