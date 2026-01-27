FROM base-system:latest

USER root
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    install kubectl /usr/local/bin/kubectl && rm kubectl && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -Lo /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-${ARCH}" && chmod +x /usr/local/bin/kind && \
    pip3 install --no-cache-dir --break-system-packages kubernetes && \
    kubectl version --client && helm version && kind version

USER agent

USER root
RUN npm install -g @kubernetes/client-node
USER agent

LABEL description="kubernetes infrastructure layer"
