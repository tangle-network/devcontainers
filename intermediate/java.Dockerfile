FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openjdk-21-jdk openjdk-21-jre maven gradle kotlin && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture) \
    PATH=/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)/bin:$PATH

USER project

LABEL description="Java/Kotlin intermediate layer"
