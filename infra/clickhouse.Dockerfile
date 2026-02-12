FROM base-system:latest

USER root
RUN curl -fsSL https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key | gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main' | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server clickhouse-client && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir --break-system-packages clickhouse-connect clickhouse-driver && \
    clickhouse-client --version

USER agent

USER root
RUN npm install -g @clickhouse/client
USER agent

LABEL description="clickhouse infrastructure layer"
