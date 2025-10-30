FROM base-system:latest

USER root
RUN npm install -g @quasar/cli quasar
USER project

LABEL description="quasar intermediate layer"
