FROM rust:latest

ENV     PATH=/root/.sp1/bin:/root/.cargo/bin:/usr/local/cargo/bin:$PATH

USER root
RUN curl -L https://sp1.succinct.xyz | bash && \
    if [ -f /root/.sp1/bin/sp1up ]; then /root/.sp1/bin/sp1up; cargo prove --version; else echo 'SP1 not installed'; fi

USER project

LABEL description="succinct infrastructure layer"
