# Fhenix Hardhat Development Container
# Multi-stage build: extracts LocalFhenix components and combines with Foundry + Hardhat tooling

# Stage 1: Extract components from Fhenix devnet image
FROM ghcr.io/fhenixprotocol/fhenix-devnet:0.1.6 AS fhenix-source

# Stage 2: Build on foundry base with all Fhenix components
FROM foundry:latest

ENV FHENIX_HOME=/opt/fhenix \
    EVMOSD_HOME=/root/.evmosd \
    FHENIX_RPC_PORT=8545 \
    FHENIX_FAUCET_PORT=6000 \
    FHENIX_CHAIN_ID=evmos_5432-1 \
    FHENIX_HELIUM_RPC=https://api.helium.fhenix.zone \
    PATH=/opt/fhenix/bin:$PATH

USER root

# Install runtime dependencies for Fhenix services
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip jq && \
    rm -rf /var/lib/apt/lists/*

# Create directory structure
RUN mkdir -p /opt/fhenix/bin /opt/fhenix/config /opt/fhenix/scripts /res/ct

# Copy Fhenix binaries from source image
COPY --from=fhenix-source /usr/bin/evmosd /opt/fhenix/bin/evmosd
COPY --from=fhenix-source /zbc-fhe-tool /opt/fhenix/bin/zbc-fhe-tool
COPY --from=fhenix-source /zbc-oracle-db /opt/fhenix/bin/zbc-oracle-db

# Copy Fhenix scripts and configs
COPY --from=fhenix-source /run.sh /opt/fhenix/scripts/run-localfhenix.sh
COPY --from=fhenix-source /faucet.js /opt/fhenix/scripts/faucet.js
COPY --from=fhenix-source /encryption_server.py /opt/fhenix/scripts/encryption_server.py
COPY --from=fhenix-source /requirements.txt /opt/fhenix/requirements.txt
COPY --from=fhenix-source /Rocket.toml /opt/fhenix/Rocket.toml
COPY --from=fhenix-source /config/ /opt/fhenix/config/

# Copy pre-configured evmosd home directory
COPY --from=fhenix-source /root/.evmosd /root/.evmosd

# Install Python dependencies for encryption server
RUN pip3 install --no-cache-dir --break-system-packages -r /opt/fhenix/requirements.txt || \
    pip3 install --no-cache-dir --break-system-packages flask || true

# Create unified startup script
RUN echo '#!/bin/bash\n\
set -e\n\
CHAIN_ID=${FHENIX_CHAIN_ID:-"evmos_5432-1"}\n\
\n\
echo "=== Starting LocalFhenix ===" \n\
echo "Chain ID: $CHAIN_ID"\n\
echo "RPC Port: $FHENIX_RPC_PORT"\n\
echo "Faucet Port: $FHENIX_FAUCET_PORT"\n\
echo ""\n\
\n\
mkdir -p /res/ct\n\
\n\
# Start FHE Oracle DB\n\
echo "Starting FHE Oracle DB..."\n\
/opt/fhenix/bin/zbc-oracle-db &\n\
\n\
# Start Faucet\n\
echo "Starting Faucet on port $FHENIX_FAUCET_PORT..."\n\
cd /opt/fhenix/scripts && node faucet.js &\n\
\n\
# Start Encryption Server\n\
echo "Starting Encryption Server..."\n\
cd /opt/fhenix/scripts && python3 encryption_server.py &\n\
\n\
# Configure evmosd\n\
/opt/fhenix/bin/evmosd config output json\n\
/opt/fhenix/bin/evmosd config chain-id $CHAIN_ID\n\
\n\
# Start evmosd\n\
echo "Starting Evmos daemon with FHE support..."\n\
/opt/fhenix/bin/evmosd start \\\n\
    --chain-id $CHAIN_ID \\\n\
    --home /root/.evmosd \\\n\
    --minimum-gas-prices=0.000000000000000001aevmos \\\n\
    --json-rpc.gas-cap=9999999999999999 \\\n\
    --gas-prices=0.00000000000000000000000000000000001aevmos \\\n\
    --json-rpc.api eth,txpool,personal,net,debug,web3\n\
' > /opt/fhenix/scripts/start-localfhenix.sh && chmod +x /opt/fhenix/scripts/start-localfhenix.sh

# Create info script
RUN mkdir -p /home/agent/.fhenix-dev/scripts && \
    echo '#!/bin/bash\n\
echo "=== Fhenix FHE Development Environment ==="\n\
echo ""\n\
echo "LocalFhenix is bundled in this container - no Docker-in-Docker required!"\n\
echo ""\n\
echo "=== Start LocalFhenix ==="\n\
echo "  /opt/fhenix/scripts/start-localfhenix.sh"\n\
echo ""\n\
echo "=== Endpoints (after starting) ==="\n\
echo "  RPC: http://127.0.0.1:8545"\n\
echo "  Faucet: curl http://127.0.0.1:6000/faucet?address=YOUR_ADDRESS"\n\
echo ""\n\
echo "=== Networks ==="\n\
echo "  LocalFhenix: http://127.0.0.1:8545"\n\
echo "  Helium Testnet: https://api.helium.fhenix.zone"\n\
echo ""\n\
echo "=== Encrypted Types ==="\n\
echo "  euint8, euint16, euint32, euint64, euint128, euint256"\n\
echo "  ebool, eaddress"\n\
echo ""\n\
echo "=== FHE Operations ==="\n\
echo "  FHE.asEuint*() - Encrypt plaintext values"\n\
echo "  FHE.add(), FHE.sub(), FHE.mul() - Arithmetic on encrypted data"\n\
echo "  FHE.and(), FHE.or(), FHE.xor() - Bitwise operations"\n\
echo "  FHE.eq(), FHE.ne(), FHE.lt(), FHE.gt() - Comparisons"\n\
echo "  FHE.select() - Conditional selection"\n\
echo "  FHE.decrypt() - Reveal encrypted value (requires permission)"\n\
echo ""\n\
echo "=== Quick Start ==="\n\
echo "  1. Import: import { FHE, euint32 } from \"@fhenixprotocol/contracts\";"\n\
echo "  2. Encrypt: euint32 secret = FHE.asEuint32(value);"\n\
echo "  3. Compute: euint32 result = FHE.add(secret, FHE.asEuint32(10));"\n\
echo ""\n\
echo "=== Docs ==="\n\
echo "  https://docs.fhenix.zone"\n\
' > /home/agent/.fhenix-dev/scripts/show-info.sh && \
    chmod +x /home/agent/.fhenix-dev/scripts/show-info.sh && \
    ln -s /opt/fhenix/scripts/start-localfhenix.sh /home/agent/.fhenix-dev/start-localfhenix.sh && \
    chown -R agent:agent /home/agent/.fhenix-dev

# Install Hardhat and Fhenix npm packages
RUN npm install -g \
    hardhat \
    @nomicfoundation/hardhat-toolbox \
    @nomicfoundation/hardhat-ethers \
    hardhat-deploy \
    hardhat-deploy-ethers \
    fhenix-hardhat-plugin \
    fhenix-hardhat-network \
    fhenixjs \
    @fhenixprotocol/contracts \
    ethers \
    viem \
    @openzeppelin/contracts \
    typechain \
    @typechain/hardhat \
    @typechain/ethers-v6

# Pre-warm npm cache
RUN npm cache add \
    fhenix-hardhat-plugin@latest \
    fhenixjs@latest \
    @fhenixprotocol/contracts@latest \
    @openzeppelin/contracts@latest

USER agent

LABEL description="Fhenix Hardhat development with embedded LocalFhenix (no Docker-in-Docker required)"
