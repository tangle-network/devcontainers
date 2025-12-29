FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages chromadb sentence-transformers && \
    python3 -c 'import chromadb; print(f"ChromaDB {chromadb.__version__}")'

USER project

USER root
RUN npm install -g chromadb chromadb-default-embed
USER project

LABEL description="chromadb infrastructure layer"
