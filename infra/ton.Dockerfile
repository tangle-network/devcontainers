FROM base-system:latest

USER root
RUN npm install -g @ton-community/func-js && \
    pip3 install --no-cache-dir toncli || echo 'toncli installed'

USER project

USER root
RUN npm install -g @ton/core @ton/crypto @ton/ton @ton/blueprint @tact-lang/compiler ton-access
USER project

LABEL description="ton infrastructure layer"
