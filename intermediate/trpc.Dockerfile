FROM base-system:latest

USER root
RUN npm install -g @trpc/server @trpc/client @trpc/react-query
USER project

LABEL description="trpc intermediate layer"
