FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=22 \
    PYTHON_VERSION=3.12 \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config libssl-dev curl wget git jq unzip ca-certificates gnupg \
    python3 python3-pip python3-venv python3-dev \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g pnpm yarn tsx \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -u 1000 project \
    && echo 'project ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /workspace && chown project:project /workspace

WORKDIR /workspace
USER project

LABEL description="CUDA intermediate layer (NVIDIA GPU support with cuDNN)"
