FROM base-system:latest

USER root
RUN npm install -g mongoose
USER project

LABEL description="mongoose intermediate layer"
