FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages chromadb && \
    python3 -c 'import chromadb; print(f"ChromaDB {chromadb.__version__}")'

USER agent

USER root
RUN npm install -g chromadb
USER agent

LABEL description="chromadb infrastructure layer"
