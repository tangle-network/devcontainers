FROM base-system:latest

USER root
RUN npm install -g vuepress @vuepress/client
USER project

LABEL description="vuepress intermediate layer"
