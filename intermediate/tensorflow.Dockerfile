FROM base-system:latest

RUN pip3 install --no-cache-dir tensorflow tensorboard

LABEL description="tensorflow intermediate layer"
