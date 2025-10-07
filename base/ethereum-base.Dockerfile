# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
###
### Echidna 
###
FROM ghcr.io/crytic/echidna/echidna:latest AS echidna

###
### Mythril
###
FROM mythril/myth:latest AS myth

###
### Foundry - Official image
###
FROM ghcr.io/foundry-rs/foundry:latest AS foundry

### Layer 2: Ethereum/Solidity Tools
FROM ${REGISTRY}/rust-base:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    git \
    jq \
    python3-pip \
    python3-venv \
    sudo \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Include echidna
COPY --chown=root:root --from=echidna /usr/local/bin/echidna /usr/local/bin/echidna

# Include mythril environment from prebuilt image
COPY --chown=root:root --from=myth /usr/local/lib  /usr/local/lib/
COPY --chown=root:root --from=myth /usr/local/bin  /usr/local/bin/
COPY --chown=root:root --from=myth /home/mythril/.mythril /root/.mythril

# Include Foundry tools from official image
COPY --chown=root:root --from=foundry /usr/local/bin/forge /usr/local/bin/forge
COPY --chown=root:root --from=foundry /usr/local/bin/cast /usr/local/bin/cast
COPY --chown=root:root --from=foundry /usr/local/bin/anvil /usr/local/bin/anvil
COPY --chown=root:root --from=foundry /usr/local/bin/chisel /usr/local/bin/chisel

# Install aderyn static analyzer
RUN npm install @cyfrin/aderyn -g

# improve compatibility with amd64 solc in non-amd64 environments (e.g. Docker Desktop on M1 Mac)
ENV QEMU_LD_PREFIX=/usr/x86_64-linux-gnu
RUN if [ ! "$(uname -m)" = "x86_64" ]; then \
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends libc6-amd64-cross \
    && rm -rf /var/lib/apt/lists/*; fi

# Foundry tools are now copied from official image above

# Nitro devnet would be installed here if needed
# Skipping for now as it's not critical

# Install python tools
RUN pip3 install --no-cache-dir --user \
    pyevmasm \
    solc-select \
    crytic-compile \
    slither-analyzer

ENV PATH="/root/.local/bin:${PATH}"

# Install essential Solidity versions with retry logic and fallback
RUN set -e && \
    echo "Installing essential Solidity versions..." && \
    ESSENTIAL_VERSIONS="0.8.30 0.8.29 0.8.28 0.8.27 0.8.26 0.8.25 0.8.24 0.8.23 0.8.22 0.8.21 0.8.20" && \
    for version in $ESSENTIAL_VERSIONS; do \
        echo "Installing Solidity $version..." && \
        for attempt in 1 2 3; do \
            if svm install "$version" 2>/dev/null && solc-select install "$version" 2>/dev/null; then \
                echo "✓ Installed Solidity $version"; \
                break; \
            else \
                echo "⚠ Attempt $attempt failed for $version"; \
                [ $attempt -eq 3 ] && echo "⚠ Skipping $version after 3 attempts" || sleep 2; \
            fi; \
        done; \
    done && \
    echo "Setting default Solidity version..." && \
    (svm use 0.8.30 2>/dev/null || svm use 0.8.29 2>/dev/null || svm use 0.8.28 2>/dev/null || echo "⚠ Could not set SVM default") && \
    (solc-select use 0.8.30 --always-install 2>/dev/null || solc-select use 0.8.29 --always-install 2>/dev/null || echo "⚠ Could not set solc-select default")

RUN cargo new --lib eth-builder && \
    cd eth-builder && \
    echo '[package]' > Cargo.toml && \
    echo 'name = "eth-builder"' >> Cargo.toml && \
    echo 'version = "0.1.0"' >> Cargo.toml && \
    echo 'edition = "2021"' >> Cargo.toml && \
    echo '' >> Cargo.toml && \
    echo '[dependencies]' >> Cargo.toml && \
    echo 'ethers = "2"' >> Cargo.toml && \
    echo 'alloy-primitives = "0.7"' >> Cargo.toml && \
    echo 'alloy-sol-types = "0.7"' >> Cargo.toml && \
    echo 'k256 = "0.13"' >> Cargo.toml && \
    echo 'secp256k1 = "0.28"' >> Cargo.toml && \
    cargo build --release && \
    rm -rf /eth-builder

# Copy cargo & foundry to /usr/local/bin for non-root user
RUN mkdir -p /usr/local/lib/python3.10/ /usr/local/share && \
    cp -a /root/.local/bin/* /usr/local/bin/ && \
    cp -a /root/.local/lib/python3.10/* /usr/local/lib/python3.10/ && \
    chmod -R a+rx /usr/local/bin/* && \
    chmod -R a+rx /usr/local/lib/python3.10/site-packages/*

ENV PYTHONPATH="${PYTHONPATH}:/usr/local/lib/python3.10/site-packages/"
ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /

LABEL description="Ethereum/Solidity development tools on Rust base"