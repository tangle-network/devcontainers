# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/base-system:latest

USER root

RUN npm install -g @coinbase/coinbase-sdk

RUN mkdir -p /workspace && \
    chown -R project:project /workspace

WORKDIR /workspace

USER project

RUN npm --version && \
    node --version

LABEL description="Coinbase development environment with SDK"

