FROM base-system:latest

USER root
RUN curl -sSL https://dl.min.io/server/minio/release/linux-amd64/minio -o /usr/local/bin/minio && chmod +x /usr/local/bin/minio && \
    curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc && \
    pip3 install --no-cache-dir minio boto3 && \
    minio --version && mc --version

USER project

USER root
RUN npm install -g minio @aws-sdk/client-s3
USER project

LABEL description="minio infrastructure layer"
