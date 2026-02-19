FROM rust:latest

ENV     PATH=/root/.local/bin:/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh && \
    curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh && \
    if [ -f /root/.local/bin/snfoundryup ]; then /root/.local/bin/snfoundryup; fi && \
    python3 -m pip install --no-cache-dir --break-system-packages --ignore-installed --upgrade pip && \
    python3 -m pip install --no-cache-dir --break-system-packages --ignore-installed cairo-lang starknet-py

USER agent

USER root
RUN npm install -g starknet get-starknet @starknet-io/types-js
USER agent

LABEL description="starknet infrastructure layer"
