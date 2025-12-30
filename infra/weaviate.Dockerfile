FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages weaviate-client && \
    python3 -c 'import weaviate; print(f"Weaviate client {weaviate.__version__}")'

USER project

USER root
RUN npm install -g weaviate-client
USER project

LABEL description="weaviate infrastructure layer"
