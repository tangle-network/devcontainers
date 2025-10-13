FROM base-system:latest

USER root
RUN npm install -g pg @types/pg
USER project

LABEL description="postgresql infrastructure layer"
