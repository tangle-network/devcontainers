FROM base-system:latest

USER root
RUN npm install -g nuxt nuxi
USER project

LABEL description="nuxt intermediate layer"
