FROM base-system:latest

USER root
RUN npm install -g vitepress
USER project

LABEL description="vitepress intermediate layer"
