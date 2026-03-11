FROM rust:latest

ENV FOUNDRY_DIR=/home/agent/.foundry \
    PATH=/home/agent/.foundry/bin:/usr/local/cargo/bin:$PATH

USER agent
RUN curl -L https://foundry.paradigm.xyz | bash \
    && /home/agent/.foundry/bin/foundryup

LABEL description="Foundry intermediate layer (forge, cast, anvil, chisel)"
