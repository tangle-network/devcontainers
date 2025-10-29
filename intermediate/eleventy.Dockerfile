FROM base-system:latest

USER root
RUN npm install -g @11ty/eleventy
USER project

LABEL description="eleventy intermediate layer"
