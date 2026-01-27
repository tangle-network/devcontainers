FROM rust:latest

# Tangle v2 - no substrate dependencies required
# blueprint-sdk v2 is substrate-free

USER root
RUN npm install -g @anthropic-ai/sdk
USER agent

LABEL description="tangle infrastructure layer (v2, substrate-free)"
