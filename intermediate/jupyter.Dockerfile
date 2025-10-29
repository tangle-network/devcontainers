FROM base-system:latest

RUN pip3 install --no-cache-dir jupyter jupyterlab notebook

LABEL description="jupyter intermediate layer"
