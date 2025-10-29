FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker.io && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN usermod -aG docker project

USER project

LABEL description="docker-cli intermediate layer"
