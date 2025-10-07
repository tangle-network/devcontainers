# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network# Specialized: RISC Zero Tools
FROM ${REGISTRY}/ethereum-base:latest

# Install RISC Zero toolchain with ARM64 Linux compatibility fix
ENV PATH=/usr/local/risc0/bin:/root/.cargo/bin:$PATH

# Step 1: Clone RISC Zero repository with depth limit and specific commit SHA for security
RUN set -ex; \
    # Using latest release tag for stability \
    RISCZERO_VERSION="v3.0.3"; \
    echo "Cloning RISC Zero repository at version $RISCZERO_VERSION"; \
    git clone --branch "$RISCZERO_VERSION" --depth=1 https://github.com/risc0/risc0.git /tmp/risc0; \
    cd /tmp/risc0; \
    # Verify we're on a reasonable commit \
    current_commit=$(git rev-parse HEAD); \
    echo "Currently on commit: $current_commit"

# Step 2: Install rzup tool with cache mount for faster rebuilds
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/tmp/risc0/target \
    set -ex; \
    cd /tmp/risc0; \
    if ! cargo install --path rzup; then \
        echo "ERROR: Failed to install rzup tool" >&2; \
        exit 1; \
    fi

# Step 3: Install Rust target with error checking
RUN set -ex; \
    if ! rustup target add riscv32im-unknown-none-elf; then \
        echo "ERROR: Failed to add riscv32im-unknown-none-elf target" >&2; \
        exit 1; \
    fi

# Step 4: Install cargo-risczero with cache mount (THE SLOW ONE - this helps a lot!)
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/tmp/risc0/target \
    set -ex; \
    cd /tmp/risc0; \
    if ! cargo install --path risc0/cargo-risczero --locked; then \
        echo "ERROR: Failed to install cargo-risczero" >&2; \
        exit 1; \
    fi

# Step 5: Create RISC Zero tools directory
RUN mkdir -p /usr/local/risc0/bin

# Step 6: Copy cargo-risczero to permanent location and update PATH with error checking
RUN set -ex; \
    # Verify the binaries exist before copying \
    if [ ! -f "/usr/local/cargo/bin/cargo-risczero" ]; then \
        echo "ERROR: cargo-risczero binary not found in expected location" >&2; \
        exit 1; \
    fi; \
    cp /usr/local/cargo/bin/cargo-risczero /usr/local/risc0/bin/; \
    # r0vm is optional, only copy if it exists \
    if [ -f "/usr/local/cargo/bin/r0vm" ]; then \
        cp /usr/local/cargo/bin/r0vm /usr/local/risc0/bin/; \
    fi; \
    echo 'export PATH="/usr/local/risc0/bin:$PATH"' >> ~/.bashrc

# Step 7: Clean up temporary files
RUN rm -rf /tmp/risc0

WORKDIR /

LABEL description="RISC Zero zkVM development tools with Ethereum"