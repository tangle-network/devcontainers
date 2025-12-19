FROM base-system:latest

# User commands (pip, go install, etc.)
RUN pip install cdp-sdk && \
    pip3 install coinbase-advanced-py && \
    pip install requests && \
    pip install cryptography && \
    pip install PyJWT && \
    pip install websockets && \
    pip install backoff

LABEL description="coinbase-developer-platform-python infrastructure layer"
