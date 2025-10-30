FROM base-system:latest

USER root
RUN npm install -g @docusaurus/core @docusaurus/preset-classic
USER project

LABEL description="docusaurus intermediate layer"
