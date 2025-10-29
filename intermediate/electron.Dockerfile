FROM base-system:latest

USER root
RUN npm install -g electron electron-builder
USER project

LABEL description="electron intermediate layer"
