FROM go:latest

USER root
RUN export HOME=/root && curl -L https://get.ignite.com/cli | bash

USER agent

LABEL description="cosmos infrastructure layer"
