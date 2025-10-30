FROM base-system:latest

USER root
RUN npm install -g expo-cli eas-cli
USER project

LABEL description="expo intermediate layer"
