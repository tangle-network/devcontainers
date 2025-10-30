FROM base-system:latest

USER root
RUN npm install -g @hapi/hapi
USER project

LABEL description="hapi intermediate layer"
