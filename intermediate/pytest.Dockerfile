FROM base-system:latest

RUN pip3 install --no-cache-dir pytest pytest-cov pytest-asyncio

LABEL description="pytest intermediate layer"
