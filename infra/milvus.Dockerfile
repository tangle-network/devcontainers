FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages pymilvus && \
    python3 -c 'from pymilvus import connections; print("PyMilvus installed")'

USER agent

USER root
RUN npm install -g @zilliz/milvus2-sdk-node
USER agent

LABEL description="milvus infrastructure layer"
