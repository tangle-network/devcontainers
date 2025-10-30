FROM base-system:latest

USER root
RUN npm install -g fastify @fastify/cli
USER project

LABEL description="fastify intermediate layer"
