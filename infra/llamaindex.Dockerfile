FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages llama-index && \
    pip3 install --no-cache-dir --break-system-packages llama-index-llms-openai llama-index-llms-anthropic llama-index-llms-ollama && \
    pip3 install --no-cache-dir --break-system-packages llama-index-embeddings-openai llama-index-embeddings-huggingface && \
    pip3 install --no-cache-dir --break-system-packages llama-index-vector-stores-chroma llama-index-vector-stores-qdrant && \
    pip3 install --no-cache-dir --break-system-packages chromadb sentence-transformers && \
    python3 -c 'import llama_index; print(f"LlamaIndex installed")'

USER project

LABEL description="llamaindex infrastructure layer"
