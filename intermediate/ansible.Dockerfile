FROM base-system:latest

RUN pip3 install --no-cache-dir ansible ansible-core

LABEL description="ansible intermediate layer"
