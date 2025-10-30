FROM base-system:latest

RUN pip3 install --no-cache-dir pandas numpy scipy matplotlib

LABEL description="pandas intermediate layer"
