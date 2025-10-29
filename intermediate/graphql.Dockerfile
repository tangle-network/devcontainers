FROM base-system:latest

USER root
RUN npm install -g graphql @apollo/server @apollo/client
USER project

LABEL description="graphql intermediate layer"
