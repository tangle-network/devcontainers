FROM base-system:latest

USER root
RUN npm install -g vitest @vitest/ui
USER project

LABEL description="vitest intermediate layer"
