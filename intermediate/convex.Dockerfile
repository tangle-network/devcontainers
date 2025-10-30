FROM base-system:latest

USER root
RUN npm install -g convex
USER project

LABEL description="convex infrastructure layer"
