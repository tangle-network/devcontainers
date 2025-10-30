FROM base-system:latest

USER root
RUN npm install -g gatsby gatsby-cli
USER project

LABEL description="gatsby intermediate layer"
