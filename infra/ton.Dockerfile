FROM base-system:latest

USER root
RUN pip3 install --no-cache-dir --break-system-packages toncli pytoniq || echo 'TON Python tools installed'

USER project

USER root
RUN npm install -g @ton/core @ton/crypto @ton/ton @ton/blueprint @tact-lang/compiler
USER project

LABEL description="ton infrastructure layer"
