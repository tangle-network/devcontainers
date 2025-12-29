FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages jupyterlab-git jupyterlab-lsp python-lsp-server[all] && \
    pip3 install --no-cache-dir --break-system-packages nbconvert nbformat papermill && \
    pip3 install --no-cache-dir --break-system-packages ipywidgets plotly bokeh altair && \
    jupyter lab --version

USER project

LABEL description="jupyter infrastructure layer"
