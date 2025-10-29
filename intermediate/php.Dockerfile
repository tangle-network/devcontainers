FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      php8.3 php8.3-cli php8.3-common php8.3-fpm \
      php8.3-mysql php8.3-pgsql php8.3-sqlite3 \
      php8.3-curl php8.3-gd php8.3-mbstring php8.3-xml php8.3-zip \
      composer && \
    rm -rf /var/lib/apt/lists/*

USER project

LABEL description="PHP language layer"
