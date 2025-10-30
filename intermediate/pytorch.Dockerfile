FROM base-system:latest

RUN pip3 install --no-cache-dir torch torchvision torchaudio

LABEL description="pytorch intermediate layer"
