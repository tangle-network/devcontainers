FROM base-system:latest

USER root
RUN npm install -g @playwright/test playwright
USER project

LABEL description="playwright intermediate layer"
