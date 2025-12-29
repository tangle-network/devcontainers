FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages tensorflow-cpu keras && \
    python3 -c 'import tensorflow as tf; print(f"TensorFlow {tf.__version__} (CPU)")'

USER project

LABEL description="tensorflow-cpu infrastructure layer"
