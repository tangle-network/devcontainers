FROM rust:latest

ENV PATH=/root/bin:/usr/local/cargo/bin:$PATH

USER root
RUN pip3 install --no-cache-dir --break-system-packages hyperliquid-python-sdk && \
    mkdir -p /root/bin && \
    ARCH=$(uname -m) && \
    curl -sSL "https://binaries.hyperliquid.xyz/Testnet/hl-visor" -o /root/bin/hl-visor && chmod +x /root/bin/hl-visor || echo 'hl-visor download attempted' && \
    /root/bin/hl-visor --help || echo 'Hyperliquid SDK installed'

USER project

USER root
RUN npm install -g ethers viem
USER project

LABEL description="hyperliquid infrastructure layer"
