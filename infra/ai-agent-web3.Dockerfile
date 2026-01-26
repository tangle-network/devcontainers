FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages langchain langchain-core langchain-openai langchain-anthropic && \
    pip3 install --no-cache-dir --break-system-packages langgraph langsmith && \
    pip3 install --no-cache-dir --break-system-packages web3 eth-account && \
    pip3 install --no-cache-dir --break-system-packages chromadb sentence-transformers && \
    python3 -c 'import langchain; import web3; print(f"LangChain {langchain.__version__}, Web3.py installed")'

USER root
RUN npm install -g @coinbase/agentkit @coinbase/cdp-sdk @x402/fetch @xmtp/xmtp-js viem wagmi langchain @langchain/core @langchain/openai @langchain/anthropic
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add @coinbase/agentkit@latest @coinbase/cdp-sdk@latest @x402/fetch@latest @xmtp/xmtp-js@latest permissionless@latest || true

LABEL description="ai-agent-web3 infrastructure layer"
