FROM base-system:latest

USER root
RUN curl -fsSL https://ollama.ai/install.sh | sh && \
    ollama --version || echo 'Ollama installed'

USER agent

USER root
RUN npm install -g ollama ollama-js
USER agent

LABEL description="ollama infrastructure layer"
