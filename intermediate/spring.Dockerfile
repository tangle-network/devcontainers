FROM java:latest

USER root
RUN curl -s https://get.sdkman.io | bash && \
    bash -c 'source /root/.sdkman/bin/sdkman-init.sh && sdk install springboot'

USER project

LABEL description="spring intermediate layer"
