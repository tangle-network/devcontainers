FROM base-system:latest

RUN pip3 install --no-cache-dir django djangorestframework

LABEL description="django intermediate layer"
