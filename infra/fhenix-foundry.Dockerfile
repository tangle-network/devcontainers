# Fhenix Foundry Development Container
# Multi-stage build: extracts LocalFhenix components and combines with Foundry tooling

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

# Create project initialization and info scripts
RUN mkdir -p /home/agent/.fhenix-foundry/scripts && \
    echo '#!/bin/bash\n\
echo "=== Fhenix Foundry Project Setup ==="\n\
echo ""\n\
if [ -f foundry.toml ]; then\n\
    echo "Foundry project already initialized"\n\
else\n\
    forge init . --no-commit\n\
    echo "Foundry project created"\n\
fi\n\
echo ""\n\
echo "Installing Fhenix dependencies..."\n\
forge install fhenixprotocol/fhenix-contracts --no-commit 2>/dev/null || echo "fhenix-contracts may already be installed"\n\
forge install fhenixprotocol/cofhe-foundry-mocks --no-commit 2>/dev/null || echo "cofhe-foundry-mocks may already be installed"\n\
forge install openzeppelin/openzeppelin-contracts --no-commit 2>/dev/null || echo "openzeppelin already installed"\n\
echo ""\n\
echo "Add these remappings to remappings.txt:"\n\
echo "@fhenixprotocol/contracts/=lib/fhenix-contracts/contracts/"\n\
echo "@fhenixprotocol/cofhe-foundry-mocks/=lib/cofhe-foundry-mocks/src/"\n\
echo "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"\n\
echo ""\n\
echo "Done! See /home/agent/.fhenix-foundry/scripts/show-info.sh for FHE development tips"\n\
' > /home/agent/.fhenix-foundry/init-project.sh && \
    echo '#!/bin/bash\n\
echo "=== Fhenix Foundry Development Environment ==="\n\
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
echo "=== Testing FHE Contracts ==="\n\
echo "The cofhe-foundry-mocks package provides mock FHE operations"\n\
echo "that simulate encryption without actual FHE computation."\n\
echo ""\n\
echo "Example test contract:"\n\
echo ""\n\
echo "  import {CoFheTest} from \"@fhenixprotocol/cofhe-foundry-mocks/CoFheTest.sol\";"\n\
echo "  import {FHE, euint32} from \"@fhenixprotocol/contracts/FHE.sol\";"\n\
echo ""\n\
echo "  contract MyTest is CoFheTest {"\n\
echo "      function testEncryptedAdd() public {"\n\
echo "          euint32 a = FHE.asEuint32(10);"\n\
echo "          euint32 b = FHE.asEuint32(20);"\n\
echo "          euint32 result = FHE.add(a, b);"\n\
echo "          assertEq(FHE.decrypt(result), 30);"\n\
echo "      }"\n\
echo "  }"\n\
echo ""\n\
echo "=== Encrypted Types ==="\n\
echo "  euint8, euint16, euint32, euint64, euint128, euint256"\n\
echo "  ebool, eaddress"\n\
echo ""\n\
echo "=== FHE Operations ==="\n\
echo "  FHE.asEuint*() - Encrypt plaintext values"\n\
echo "  FHE.add(), FHE.sub(), FHE.mul() - Arithmetic"\n\
echo "  FHE.and(), FHE.or(), FHE.xor() - Bitwise"\n\
echo "  FHE.eq(), FHE.ne(), FHE.lt(), FHE.gt() - Comparisons"\n\
echo "  FHE.select() - Conditional selection"\n\
echo "  FHE.decrypt() - Reveal encrypted value"\n\
echo ""\n\
echo "=== Deployment ==="\n\
echo "  Local: forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast"\n\
echo "  Testnet: forge script script/Deploy.s.sol --rpc-url \$FHENIX_HELIUM_RPC --broadcast"\n\
echo ""\n\
echo "=== Notes ==="\n\
echo "  1. Mock operations do NOT reflect real FHE gas costs"\n\
echo "  2. Security zones are not enforced in mocks"\n\
echo "  3. Use LocalFhenix for integration testing with real FHE"\n\
echo ""\n\
echo "=== Docs ==="\n\
echo "  https://docs.fhenix.zone"\n\
echo "  https://github.com/FhenixProtocol/fhenix-foundry-template"\n\
echo "  https://github.com/FhenixProtocol/cofhe-foundry-mocks"\n\
' > /home/agent/.fhenix-foundry/scripts/show-info.sh && \
    chmod +x /home/agent/.fhenix-foundry/*.sh /home/agent/.fhenix-foundry/scripts/*.sh && \
    ln -s /opt/fhenix/scripts/start-localfhenix.sh /home/agent/.fhenix-foundry/start-localfhenix.sh && \
    chown -R agent:agent /home/agent/.fhenix-foundry

# Install minimal npm packages for Fhenix JS SDK
RUN npm install -g fhenixjs ethers viem

# Pre-warm npm cache
RUN npm cache add fhenixjs@latest @openzeppelin/contracts@latest || true

USER agent

LABEL description="Fhenix Foundry development with embedded LocalFhenix (no Docker-in-Docker required)"
