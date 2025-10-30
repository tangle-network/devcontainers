FROM base-system:latest

USER root
RUN npm install -g @angular/cli @angular/core
USER project

LABEL description="angular intermediate layer"
