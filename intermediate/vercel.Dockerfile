FROM base-system:latest

USER root
RUN npm install -g vercel
USER project

LABEL description="vercel framework layer"
