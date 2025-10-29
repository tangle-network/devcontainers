FROM rust:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libwebkit2gtk-4.0-dev libgtk-3-dev libayatana-appindicator3-dev && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN npm install -g @tauri-apps/cli
USER project

RUN cargo install tauri-cli

LABEL description="tauri intermediate layer"
