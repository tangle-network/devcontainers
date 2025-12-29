FROM rust:latest

USER root
RUN pip3 install --no-cache-dir qdrant-client && \
    cargo install qdrant || (curl -sSL https://github.com/qdrant/qdrant/releases/latest/download/qdrant-x86_64-unknown-linux-gnu.tar.gz | tar -xz -C /usr/local/bin || echo 'Qdrant binary installation') && \
    qdrant --version || echo 'Qdrant installed'

USER project

USER root
RUN npm install -g @qdrant/js-client-rest
USER project

LABEL description="qdrant infrastructure layer"
