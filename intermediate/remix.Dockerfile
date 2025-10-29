FROM base-system:latest

USER root
RUN npm install -g @remix-run/node @remix-run/react @remix-run/serve create-remix
USER project

LABEL description="remix intermediate layer"
