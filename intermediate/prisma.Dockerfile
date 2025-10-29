FROM base-system:latest

USER root
RUN npm install -g prisma @prisma/client
USER project

LABEL description="prisma intermediate layer"
