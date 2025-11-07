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
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g corepack \
    && corepack prepare pnpm yarn --activate \
    && npm install -g patch-package vite tsx turbo typescript @types/node node-pty \
    && npm install -g opencode-ai \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install Factory Droids CLI
RUN curl -fsSL https://app.factory.ai/cli | sh

# Create project user and group for secure operations
# Use the existing ubuntu user (UID/GID 1000) and add to sudoers
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -l project -d /home/project -m ubuntu && \
    groupmod -n project ubuntu && \
    # Create appuser as an alias for project user for MCP compatibility \
    useradd --uid 1001 --gid 1000 --shell /bin/bash --home-dir /home/project --no-create-home appuser && \
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
RUN mkdir -p /home/project /tmp/.npm-cache /tmp/.pnpm-store && \
    chown -R project:project /home/project /tmp/.npm-cache /tmp/.pnpm-store && \
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
    chown -R project:project /pnpm

# Set up workspace with proper permissions
RUN mkdir -p /workspace && \
    chown -R project:project /workspace

WORKDIR /workspace

# Switch to project user for safer operations
USER project

# Verify npm and pnpm work correctly as project user
RUN npm --version && \
    pnpm --version && \
    node --version && \
    npm config get registry && \
    pnpm config get registry

LABEL description="Base system with Node.js for all MCP services"
