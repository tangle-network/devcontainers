# syntax=docker/dockerfile:1.4
ARG REGISTRY=ghcr.io/tangle-network
FROM ${REGISTRY}/ethereum-base:latest

RUN npm install -g \
    ethers \
    viem \
    @wagmi/core \
    hardhat \
    @openzeppelin/contracts

WORKDIR /workspace

LABEL description="Ethereum/Polygon/zkSync development environment with additional libraries"

