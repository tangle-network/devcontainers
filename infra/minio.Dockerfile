FROM base-system:latest

USER root
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    curl -sSL "https://dl.min.io/server/minio/release/linux-${ARCH}/minio" -o /usr/local/bin/minio && chmod +x /usr/local/bin/minio && \
    curl -sSL "https://dl.min.io/client/mc/release/linux-${ARCH}/mc" -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc && \
    pip3 install --no-cache-dir --break-system-packages minio boto3 && \
    minio --version && mc --version

USER agent

USER root
RUN npm install -g minio @aws-sdk/client-s3
USER agent

LABEL description="minio infrastructure layer"
