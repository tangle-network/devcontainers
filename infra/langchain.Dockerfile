FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages langchain langchain-core langchain-community langchain-openai langchain-anthropic && \
    pip3 install --no-cache-dir --break-system-packages langgraph langsmith langserve && \
    pip3 install --no-cache-dir --break-system-packages chromadb faiss-cpu sentence-transformers && \
    python3 -c 'import langchain; print(f"LangChain {langchain.__version__}")'

USER agent

USER root
RUN npm install -g langchain @langchain/core @langchain/openai @langchain/anthropic @langchain/community
USER agent

# Pre-warm pip cache with project-specific packages
RUN pip download --break-system-packages --dest /tmp/pip-warm openai anthropic tiktoken chromadb sentence-transformers && rm -rf /tmp/pip-warm

LABEL description="langchain infrastructure layer"
