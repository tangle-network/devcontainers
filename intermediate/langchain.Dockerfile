FROM base-system:latest

RUN pip3 install --no-cache-dir langchain langchain-openai langchain-community

LABEL description="langchain intermediate layer"
