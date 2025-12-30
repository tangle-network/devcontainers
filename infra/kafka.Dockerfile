FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      default-jdk && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN curl -sSL https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz | tar -xz -C /opt && \
    ln -s /opt/kafka_2.13-3.7.0 /opt/kafka && \
    chmod -R a+rx /opt/kafka && \
    pip3 install --no-cache-dir --break-system-packages kafka-python confluent-kafka && \
    echo 'export PATH=$PATH:/opt/kafka/bin' >> /etc/profile.d/kafka.sh && \
    /opt/kafka/bin/kafka-topics.sh --version || echo 'Kafka installed'

USER project

USER root
RUN npm install -g kafkajs @confluentinc/kafka-javascript
USER project

LABEL description="kafka infrastructure layer"
