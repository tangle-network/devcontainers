FROM base-system:latest

USER root
RUN npm install -g mysql2
USER project

LABEL description="mysql blueprint"
