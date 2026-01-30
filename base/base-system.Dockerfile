# syntax=docker/dockerfile:1.4
# Layer 0: Base System - Common to ALL services
FROM ubuntu:24.04

# System dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential pkg-config libssl-dev libudev-dev \
      curl wget git jq rsync make cmake gcc g++ llvm procps \
      ca-certificates tini libclang-dev libjemalloc-dev sudo \
      python3 python3-pip python3-setuptools python3-venv; \
    rm -rf /var/lib/apt/lists/*

# Node.js 22 + package managers + common tools
# Note: opencode-ai is installed by the sidecar, not here
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g corepack \
    && corepack prepare pnpm yarn --activate \
    && npm install -g patch-package vite tsx turbo typescript @types/node node-pty \
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

# Create agent user and group for secure operations
# Use the existing ubuntu user (UID/GID 1000) and add to sudoers
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -l agent -d /home/agent -m ubuntu && \
    groupmod -n agent ubuntu && \
    # Create appuser as an alias for agent user for MCP compatibility \
    useradd --uid 1001 --gid 1000 --shell /bin/bash --home-dir /home/agent --no-create-home appuser && \
    echo 'appuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set up npm configuration for better caching and performance
RUN npm config set cache /tmp/.npm-cache --global \
    && npm config set prefer-offline false --global \
    && npm config set registry https://registry.npmjs.org/ --global \
    && npm config set fetch-retries 3 --global \
    && npm config set fetch-retry-factor 10 --global \
    && npm config set fetch-retry-mintimeout 10000 --global \
    && npm config set fetch-retry-maxtimeout 60000 --global \
    && npm config set maxsockets 15 --global \
    && npm config set legacy-peer-deps false --global

# Create common directories with secure permissions
RUN mkdir -p /home/agent /home/agent/workspace /tmp/.npm-cache /tmp/.pnpm-store && \
    chown -R agent:agent /home/agent /tmp/.npm-cache /tmp/.pnpm-store && \
    chmod -R 755 /tmp/.npm-cache /tmp/.pnpm-store

# Clear npm cache and set pnpm store directory with proper ownership
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm cache clean --force && \
    pnpm config set store-dir /tmp/.pnpm-store && \
    pnpm config set registry https://registry.npmjs.org/ && \
    pnpm config set fetch-retries 3 && \
    pnpm config set fetch-retry-factor 10 && \
    pnpm config set fetch-retry-mintimeout 10000 && \
    pnpm config set fetch-retry-maxtimeout 60000 && \
    mkdir -p /pnpm && \
    chown -R agent:agent /pnpm

# Set up workspace with proper permissions
RUN chown -R agent:agent /home/agent/workspace

WORKDIR /home/agent/workspace

# Switch to agent user for safer operations
USER agent

# Verify npm and pnpm work correctly as agent user
RUN npm --version && \
    pnpm --version && \
    node --version && \
    npm config get registry && \
    pnpm config get registry

LABEL description="Base system with Node.js for all MCP services"
