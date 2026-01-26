FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      default-jdk && \
    rm -rf /var/lib/apt/lists/*

USER agent

USER root
RUN curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main' | tee /etc/apt/sources.list.d/elastic-8.x.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y elasticsearch && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir --break-system-packages elasticsearch && \
    echo 'Elasticsearch installed (run with: systemctl start elasticsearch)'

USER agent

USER root
RUN npm install -g @elastic/elasticsearch elasticsearch
USER agent

LABEL description="elasticsearch infrastructure layer"
