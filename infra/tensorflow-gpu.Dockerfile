FROM cuda:latest

USER root
RUN pip3 install --no-cache-dir tensorflow[and-cuda] keras && \
    pip3 install --no-cache-dir numpy scipy pandas matplotlib seaborn scikit-learn jupyter jupyterlab && \
    python3 -c 'import tensorflow as tf; print(f"TensorFlow {tf.__version__}, GPU: {len(tf.config.list_physical_devices("GPU"))} devices")'

USER project

LABEL description="tensorflow-gpu infrastructure layer"
