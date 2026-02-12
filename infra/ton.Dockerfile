FROM base-system:latest

USER root
RUN npm install -g @ton-community/func-js && \
    pip3 install --no-cache-dir --break-system-packages toncli || echo 'toncli installed'

USER agent

USER root
RUN npm install -g @ton/core @ton/crypto @ton/ton @ton/blueprint @tact-lang/compiler ton-access
USER agent

LABEL description="ton infrastructure layer"
