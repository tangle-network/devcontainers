FROM base-system:latest

RUN pip3 install --no-cache-dir fastapi uvicorn python-multipart

LABEL description="fastapi intermediate layer"
