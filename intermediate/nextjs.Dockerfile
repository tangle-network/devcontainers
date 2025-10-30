FROM base-system:latest

USER root
RUN npm install -g next react react-dom create-next-app
USER project

LABEL description="nextjs intermediate layer"
