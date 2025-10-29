FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN npm install -g react-native @react-native-community/cli
USER project

LABEL description="react-native intermediate layer"
