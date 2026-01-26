FROM rust:latest

ENV PATH=/root/.foundry/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl -L https://foundry.paradigm.xyz | bash \
    && /root/.foundry/bin/foundryup \
    && chmod -R a+rx /root/.foundry

USER agent

LABEL description="Foundry intermediate layer (forge, cast, anvil, chisel)"
