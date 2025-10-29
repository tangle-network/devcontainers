FROM base-system:latest

USER root
RUN npm install -g koa @types/koa koa-router
USER project

LABEL description="koa intermediate layer"
