FROM base-system:latest

USER root
RUN npm install -g @nestjs/cli @nestjs/core @nestjs/common
USER project

LABEL description="nestjs intermediate layer"
