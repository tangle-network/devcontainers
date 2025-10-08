# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/sui-base:latest

USER root

RUN npm install -g @mysten/sui.js

USER rust

WORKDIR /workspace

LABEL description="Sui blockchain development environment with SDK"

