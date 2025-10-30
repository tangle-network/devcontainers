FROM base-system:latest

USER root
RUN npm install -g redis ioredis
USER project

LABEL description="redis infrastructure layer"
