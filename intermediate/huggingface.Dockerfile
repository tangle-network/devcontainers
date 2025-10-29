FROM base-system:latest

RUN pip3 install --no-cache-dir transformers datasets accelerate

LABEL description="huggingface intermediate layer"
