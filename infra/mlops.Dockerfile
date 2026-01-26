FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages mlflow wandb && \
    pip3 install --no-cache-dir --break-system-packages optuna ray[tune] && \
    pip3 install --no-cache-dir --break-system-packages dvc great-expectations && \
    pip3 install --no-cache-dir --break-system-packages onnx onnxruntime && \
    mlflow --version && wandb --version

USER agent

LABEL description="mlops infrastructure layer"
