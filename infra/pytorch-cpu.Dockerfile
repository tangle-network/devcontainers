FROM scientific-python:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    python3 -c 'import torch; print(f"PyTorch {torch.__version__} (CPU)")'

USER agent

LABEL description="pytorch-cpu infrastructure layer"
