FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      postgresql postgresql-contrib libpq-dev && \
    rm -rf /var/lib/apt/lists/*

USER agent

USER root
RUN apt-get update && apt-get install -y postgresql-16-pgvector && rm -rf /var/lib/apt/lists/* && \
    pip3 install --no-cache-dir pgvector psycopg2-binary sqlalchemy && \
    echo 'PostgreSQL with pgvector extension installed'

USER agent

USER root
RUN npm install -g pg pgvector @types/pg
USER agent

LABEL description="pgvector infrastructure layer"
