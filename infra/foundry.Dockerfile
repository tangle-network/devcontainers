FROM rust:latest

ENV     PATH=/root/.foundry/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl -L https://foundry.paradigm.xyz | bash && \
    if [ -f /root/.foundry/bin/foundryup ]; then /root/.foundry/bin/foundryup; else echo 'Foundry not installed'; fi

USER project

LABEL description="foundry infrastructure layer"
