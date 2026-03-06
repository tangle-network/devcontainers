# syntax=docker/dockerfile:1.4
# Layer 0: Base System - Common to ALL services
FROM ubuntu:24.04

# Version pins for toolchain binaries
ARG OPENCODE_VERSION=1.1.46
ARG BUN_VERSION=1.3.5
ARG SCCACHE_VERSION=0.8.1
ARG NEWT_VERSION=1.10.0
ARG MISE_VERSION=2026.1.1
ARG GH_VERSION=2.65.0

# System dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential pkg-config libssl-dev libudev-dev \
      curl wget git jq rsync make cmake gcc g++ llvm procps \
      ca-certificates tini libclang-dev libjemalloc-dev sudo \
      python3 python3-pip python3-setuptools python3-venv \
      unzip ripgrep; \
    rm -rf /var/lib/apt/lists/*

# Node.js 22 + package managers + common tools
# Note: opencode binary is installed separately below
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g corepack \
    && corepack prepare pnpm yarn --activate \
    && npm install -g patch-package vite tsx turbo typescript @types/node node-pty@1.0.0 \
    && rm -rf /var/lib/apt/lists/*

# LSP servers for code intelligence
# These enable language server protocol support in the agent IDE
RUN npm install -g \
    typescript-language-server \
    bash-language-server \
    vscode-langservers-extracted \
    pyright

# Install clangd for C/C++ support
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends clangd && \
    rm -rf /var/lib/apt/lists/*

# Install marksman for Markdown LSP support
RUN MARKSMAN_VERSION="2024-12-18" && \
    arch="$(uname -m)" && \
    case "$arch" in \
        x86_64) marksman_arch="marksman-linux-x64" ;; \
        aarch64) marksman_arch="marksman-linux-arm64" ;; \
        *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/artempyanykh/marksman/releases/download/${MARKSMAN_VERSION}/${marksman_arch}" -o /usr/local/bin/marksman && \
    chmod +x /usr/local/bin/marksman

# Create default LSP configuration for agents
# This provides baseline language server support when no user config exists
# Languages with binaries not installed will gracefully fail to start
RUN mkdir -p /etc/opencode
COPY <<'EOFCONFIG' /etc/opencode/opencode.config.json
{
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": ["ts", "tsx"]
    },
    "javascript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": ["js", "jsx", "mjs", "cjs"]
    },
    "python": {
      "command": ["pyright-langserver", "--stdio"],
      "extensions": ["py"]
    },
    "rust": {
      "command": ["rust-analyzer"],
      "extensions": ["rs"]
    },
    "go": {
      "command": ["gopls", "serve"],
      "extensions": ["go"]
    },
    "bash": {
      "command": ["bash-language-server", "start"],
      "extensions": ["sh", "bash"]
    },
    "json": {
      "command": ["vscode-json-language-server", "--stdio"],
      "extensions": ["json", "jsonc"]
    },
    "css": {
      "command": ["vscode-css-language-server", "--stdio"],
      "extensions": ["css", "scss", "sass", "less"]
    },
    "html": {
      "command": ["vscode-html-language-server", "--stdio"],
      "extensions": ["html", "htm"]
    },
    "markdown": {
      "command": ["marksman", "server"],
      "extensions": ["md", "mdx"]
    },
    "cpp": {
      "command": ["clangd"],
      "extensions": ["c", "cc", "cpp", "cxx", "h", "hpp"]
    }
  }
}
EOFCONFIG

# Pre-warm npm cache with commonly used packages
# This populates the npm cache so first `npm install` for these packages is instant
# These packages cover: React ecosystem, build tools, testing, styling, utilities
RUN npm cache add \
    # React ecosystem
    react@latest react-dom@latest @types/react@latest @types/react-dom@latest \
    next@latest @next/env@latest \
    # Build & bundling
    vite@latest @vitejs/plugin-react@latest esbuild@latest rollup@latest \
    # TypeScript
    typescript@latest @types/node@latest ts-node@latest \
    # Testing
    vitest@latest @vitest/ui@latest jest@latest @types/jest@latest \
    # Styling
    tailwindcss@latest postcss@latest autoprefixer@latest \
    # Server frameworks
    express@latest @types/express@latest fastify@latest hono@latest \
    # Utilities
    zod@latest dotenv@latest axios@latest lodash@latest @types/lodash@latest \
    # Database/ORM
    drizzle-orm@latest prisma@latest @prisma/client@latest \
    # Linting & formatting
    eslint@latest prettier@latest @typescript-eslint/parser@latest @typescript-eslint/eslint-plugin@latest \
    # Monorepo tools
    turbo@latest || true

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install Factory Droids CLI
RUN curl -fsSL https://app.factory.ai/cli | sh

# Install CLI tools: OpenCode, Bun, sccache, Newt, mise, GitHub CLI
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  deb_arch="amd64"; short_arch="x64"; bun_arch="x64" ;; \
        aarch64) deb_arch="arm64"; short_arch="arm64"; bun_arch="aarch64" ;; \
        *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac; \
    # Detect musl vs glibc for Alpine compatibility \
    if ldd /bin/sh 2>&1 | grep -q musl; then musl_suffix="-musl"; else musl_suffix=""; fi; \
    # --- OpenCode (uses x64/arm64) --- \
    curl -fsSL "https://github.com/sst/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${short_arch}${musl_suffix}.tar.gz" \
      | tar -xzf - -C /usr/local/bin; \
    chmod +x /usr/local/bin/opencode; \
    # --- Bun (uses x64/aarch64) --- \
    curl -fsSL "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-${bun_arch}${musl_suffix}.zip" -o /tmp/bun.zip; \
    unzip -oq /tmp/bun.zip -d /tmp/bun-install; \
    mv /tmp/bun-install/bun-linux-${bun_arch}${musl_suffix}/bun /usr/local/bin/bun; \
    chmod +x /usr/local/bin/bun; \
    rm -rf /tmp/bun.zip /tmp/bun-install; \
    # --- sccache (uses x86_64/aarch64) --- \
    curl -fsSL "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${arch}-unknown-linux-musl.tar.gz" \
      | tar -xzf - --strip-components=1 -C /usr/local/bin "sccache-v${SCCACHE_VERSION}-${arch}-unknown-linux-musl/sccache"; \
    chmod +x /usr/local/bin/sccache; \
    # --- Newt (uses amd64/arm64) --- \
    curl -fsSL "https://github.com/fosrl/newt/releases/download/${NEWT_VERSION}/newt_linux_${deb_arch}" -o /usr/local/bin/newt; \
    chmod +x /usr/local/bin/newt; \
    # --- mise (uses x64/arm64, binary at mise/bin/mise) --- \
    curl -fsSL "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-${short_arch}${musl_suffix}.tar.gz" \
      | tar -xzf - --strip-components=2 -C /usr/local/bin mise/bin/mise; \
    chmod +x /usr/local/bin/mise; \
    # --- GitHub CLI (uses amd64/arm64) --- \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${deb_arch}.tar.gz" \
      | tar -xzf - --strip-components=2 -C /usr/local/bin "gh_${GH_VERSION}_linux_${deb_arch}/bin/gh"; \
    chmod +x /usr/local/bin/gh

# Git credential helper for GitHub token auth
COPY <<'EOF' /usr/local/bin/git-credential-github-token
#!/bin/sh
if [ "$1" = "get" ] && [ -n "$GITHUB_TOKEN" ]; then
  echo "username=x-access-token"
  echo "password=$GITHUB_TOKEN"
fi
EOF
RUN chmod +x /usr/local/bin/git-credential-github-token && \
    git config --system credential.helper /usr/local/bin/git-credential-github-token

# Create agent user and group for secure operations
# Use the existing ubuntu user (UID/GID 1000) and add to sudoers
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -l agent -d /home/agent -m ubuntu && \
    groupmod -n agent ubuntu

# Consolidated environment variables
ENV SHELL=/bin/bash \
    HOME=/home/agent \
    NPM_CONFIG_CACHE=/home/agent/.cache/npm \
    PNPM_HOME=/home/agent/.local/share/pnpm \
    npm_config_store_dir=/home/agent/.pnpm-store \
    CARGO_HOME=/home/agent/.cargo \
    PIP_CACHE_DIR=/home/agent/.cache/pip \
    SCCACHE_DIR=/home/agent/.cache/sccache \
    GOMODCACHE=/home/agent/.cache/go \
    MISE_DATA_DIR=/home/agent/.local/share/mise \
    MISE_CACHE_DIR=/home/agent/.cache/mise \
    MISE_YES=1 \
    XDG_DATA_HOME=/home/agent/.local/share \
    XDG_CONFIG_HOME=/home/agent/.config \
    XDG_CACHE_HOME=/home/agent/.cache \
    XDG_STATE_HOME=/home/agent/.local/state \
    PATH="/home/agent/.local/share/pnpm:/home/agent/.local/share/mise/shims:/home/agent/.local/bin:/home/agent/.cargo/bin:$PATH"

# npm configuration
RUN npm config set prefer-offline false --global \
    && npm config set registry https://registry.npmjs.org/ --global \
    && npm config set fetch-retries 3 --global \
    && npm config set fetch-retry-factor 10 --global \
    && npm config set fetch-retry-mintimeout 10000 --global \
    && npm config set fetch-retry-maxtimeout 60000 --global \
    && npm config set maxsockets 15 --global \
    && npm config set legacy-peer-deps false --global

# pnpm configuration
RUN npm cache clean --force && \
    pnpm config set store-dir /home/agent/.pnpm-store && \
    pnpm config set registry https://registry.npmjs.org/ && \
    pnpm config set fetch-retries 3 && \
    pnpm config set fetch-retry-factor 10 && \
    pnpm config set fetch-retry-mintimeout 10000 && \
    pnpm config set fetch-retry-maxtimeout 60000

# Create all directories with proper permissions
RUN mkdir -p \
    /home/agent/.cache/npm \
    /home/agent/.cache/pip \
    /home/agent/.cache/mise \
    /home/agent/.cache/sccache \
    /home/agent/.cache/go \
    /home/agent/.local/share/pnpm \
    /home/agent/.pnpm-store \
    /home/agent/.cargo \
    /home/agent/.local/bin \
    /home/agent/.local/share \
    /home/agent/.local/share/mise \
    /home/agent/.local/share/mise/shims \
    /home/agent/.local/state \
    /home/agent/.config \
    /home/agent/.sidecar/state \
    /home/agent/workspace && \
    chmod -R 777 /home/agent

# Sidecar mount points (populated via bind mounts at runtime)
RUN mkdir -p /sidecar /shared && \
    chmod 755 /sidecar /shared

# Module resolution symlinks for sidecar
RUN mkdir -p /sidecar/node_modules/@repo && \
    ln -sf $(npm root -g)/node-pty /sidecar/node_modules/node-pty && \
    ln -sf /shared /sidecar/node_modules/@repo/shared

WORKDIR /home/agent

# Switch to agent user for safer operations
USER agent

# Verify tools work correctly as agent user
RUN npm --version && \
    pnpm --version && \
    node --version && \
    bun --version && \
    gh --version && \
    mise --version && \
    sccache --version && \
    rg --version && \
    npm list -g node-pty && \
    npm config get registry && \
    pnpm config get registry && \
    (opencode --version || true)

EXPOSE 8080

LABEL description="Base system with Node.js for all MCP services"
LABEL agent.sidecar=layered
LABEL agent.sidecar.version=2.0
