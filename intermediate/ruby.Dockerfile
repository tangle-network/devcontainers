FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ruby ruby-dev ruby-bundler && \
    rm -rf /var/lib/apt/lists/*

USER project

LABEL description="Ruby intermediate layer"
