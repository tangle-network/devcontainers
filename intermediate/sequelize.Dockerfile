FROM base-system:latest

USER root
RUN npm install -g sequelize sequelize-cli
USER project

LABEL description="sequelize intermediate layer"
