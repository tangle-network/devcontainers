FROM base-system:latest

USER root
RUN npm install -g firebase-tools firebase-admin
USER project

LABEL description="firebase intermediate layer"
