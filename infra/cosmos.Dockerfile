FROM go:latest

USER root
RUN curl -L https://get.ignite.com/cli | bash

USER agent

LABEL description="cosmos infrastructure layer"
