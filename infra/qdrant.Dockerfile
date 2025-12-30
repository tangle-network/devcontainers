FROM rust:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages qdrant-client && \
    python3 -c 'from qdrant_client import QdrantClient; print("Qdrant client installed")'

USER project

USER root
RUN npm install -g @qdrant/js-client-rest
USER project

LABEL description="qdrant infrastructure layer"
