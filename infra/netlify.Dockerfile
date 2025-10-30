FROM base-system:latest

USER root
RUN npm install -g netlify-cli
USER project

LABEL description="netlify framework layer"
