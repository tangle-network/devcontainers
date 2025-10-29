FROM base-system:latest

USER root
RUN npm install -g @strapi/strapi create-strapi-app
USER project

LABEL description="strapi intermediate layer"
