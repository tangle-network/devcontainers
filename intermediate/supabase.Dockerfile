FROM base-system:latest

USER root
RUN npm install -g supabase
USER project

LABEL description="supabase intermediate layer"
