FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir weaviate-client && \
    python3 -c 'import weaviate; print(f"Weaviate client {weaviate.__version__}")'

USER agent

USER root
RUN npm install -g weaviate-ts-client weaviate-client
USER agent

LABEL description="weaviate infrastructure layer"
