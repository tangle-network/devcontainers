FROM base-system:latest

USER root
RUN curl -fsSL https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key | gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main' | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update && apt-get install -y clickhouse-server clickhouse-client && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir clickhouse-connect clickhouse-driver && \
    clickhouse-client --version

USER project

USER root
RUN npm install -g @clickhouse/client
USER project

LABEL description="clickhouse infrastructure layer"
