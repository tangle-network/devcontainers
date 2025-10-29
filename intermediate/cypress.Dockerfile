FROM base-system:latest

USER root
RUN npm install -g cypress
USER project

LABEL description="cypress intermediate layer"
