FROM base-system:latest

USER root
RUN npm install -g vue @vue/cli create-vue
USER project

LABEL description="vue intermediate layer"
