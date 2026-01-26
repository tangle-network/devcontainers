FROM base-system:latest

USER root
RUN npm install -g pg @types/pg
USER agent

LABEL description="postgresql infrastructure layer"
