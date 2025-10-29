FROM base-system:latest

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      clang llvm lld libstdc++-13-dev libc++-dev libc++abi-dev \
      libboost-all-dev libsodium-dev libsecp256k1-dev \
      cmake ninja-build autoconf automake libtool && \
    rm -rf /var/lib/apt/lists/*

USER project

LABEL description="C/C++ language layer"
