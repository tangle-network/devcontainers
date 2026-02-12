FROM base-system:latest

USER root
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main' | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && rm -rf /var/lib/apt/lists/* && \
    curl -sSL https://get.opentofu.org/install-opentofu.sh | bash -s -- --install-method deb && \
    pip3 install --no-cache-dir python-terraform && \
    terraform version && tofu version

USER agent

USER root
RUN npm install -g cdktf-cli @cdktf/provider-aws @cdktf/provider-google
USER agent

LABEL description="terraform infrastructure layer"
