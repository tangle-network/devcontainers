FROM base-system:latest

USER root
RUN npm install -g drizzle-orm drizzle-kit
USER project

LABEL description="drizzle intermediate layer"
