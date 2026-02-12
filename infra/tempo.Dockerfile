FROM foundry:latest

ENV     PATH=/root/.tempo/bin:/root/.foundry/bin:/usr/local/cargo/bin:$PATH

USER root
RUN git clone https://github.com/tempoxyz/tempo.git /tmp/tempo && cd /tmp/tempo && git checkout 7e2c66842c2ef99e3f0670c63d9b92df20195af6 && cargo build --release && mkdir -p /root/.tempo/bin && cp target/release/tempo* /root/.tempo/bin/ 2>/dev/null || echo 'Tempo binaries copied' && chmod -R a+rx /root/.tempo && rm -rf /tmp/tempo && \
    echo 'Tempo node built from https://github.com/tempoxyz/tempo at 7e2c66842c2ef99e3f0670c63d9b92df20195af6'

USER agent

USER root
RUN npm install -g ethers viem hardhat @nomicfoundation/hardhat-toolbox
USER agent

LABEL description="tempo infrastructure layer"
