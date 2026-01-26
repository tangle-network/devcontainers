FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gnupg && \
    rm -rf /var/lib/apt/lists/*

USER agent

USER root
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg && \
    echo 'deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse' | tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/db && chmod 777 /data/db && \
    mongod --version

USER agent

USER root
RUN npm install -g mongodb mongoose
USER agent

LABEL description="mongodb infrastructure layer"
