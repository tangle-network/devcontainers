FROM scientific-python:latest

USER root
# Use tensorflow (not tensorflow-cpu) for arm64 compatibility
RUN pip3 install --no-cache-dir --break-system-packages tensorflow keras && \
    python3 -c 'import tensorflow as tf; print(f"TensorFlow {tf.__version__} (CPU)")'

USER agent

LABEL description="tensorflow-cpu infrastructure layer"
