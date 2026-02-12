FROM rust:latest

ENV     PATH=/root/bin:/usr/local/cargo/bin:$PATH

USER root
RUN pip3 install --no-cache-dir --break-system-packages hyperliquid-python-sdk && \
    mkdir -p /root/bin && curl -sSL https://binaries.hyperliquid.xyz/Testnet/hl-visor -o /root/bin/hl-visor && chmod +x /root/bin/hl-visor && \
    git clone https://github.com/hyperliquid-dex/node.git /opt/hyperliquid-node && cd /opt/hyperliquid-node && git checkout 8a2c4b9e5757aafae5079f8236e3bf6752f7d81b && chmod -R a+r /opt/hyperliquid-node && \
    /root/bin/hl-visor --help || echo 'Hyperliquid visor installed'

USER agent

USER root
RUN npm install -g ethers viem
USER agent

LABEL description="hyperliquid infrastructure layer"
