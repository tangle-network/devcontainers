FROM base-system:latest

USER root
RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir --break-system-packages redis hiredis && \
    redis-server --version

USER agent

USER root
RUN npm install -g redis ioredis
USER agent

LABEL description="redis infrastructure layer"
