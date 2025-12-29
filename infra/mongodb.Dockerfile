FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gnupg && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg && \
    echo 'deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse' | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && apt-get install -y mongodb-org && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/db && chmod 777 /data/db && \
    mongod --version

USER project

USER root
RUN npm install -g mongodb mongoose @types/mongoose mongosh
USER project

LABEL description="mongodb infrastructure layer"
