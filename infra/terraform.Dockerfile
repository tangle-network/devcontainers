FROM base-system:latest

USER root
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main' | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir --break-system-packages python-terraform && \
    terraform version

USER agent

USER root
RUN npm install -g cdktf-cli
USER agent

LABEL description="terraform infrastructure layer"
