FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir pymilvus && \
    curl -sSL https://raw.githubusercontent.com/milvus-io/milvus/master/scripts/standalone_embed.sh -o /usr/local/bin/milvus-standalone.sh && chmod +x /usr/local/bin/milvus-standalone.sh && \
    python3 -c 'from pymilvus import connections; print("PyMilvus installed")'

USER agent

LABEL description="milvus infrastructure layer"
