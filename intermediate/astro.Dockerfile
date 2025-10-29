FROM base-system:latest

USER root
RUN npm install -g astro create-astro
USER project

LABEL description="astro intermediate layer"
