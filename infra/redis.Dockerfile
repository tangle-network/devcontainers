FROM base-system:latest

USER root
RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir redis hiredis && \
    redis-server --version

USER project

USER root
RUN npm install -g redis ioredis @redis/client
USER project

LABEL description="redis infrastructure layer"
