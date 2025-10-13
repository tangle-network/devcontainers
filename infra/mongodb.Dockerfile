FROM base-system:latest

USER root
RUN npm install -g mongodb
USER project

LABEL description="mongodb infrastructure layer"
