FROM base-system:latest

ENV GOROOT=/usr/local/go \
    GOPATH=/go \
    PATH=/usr/local/go/bin:/go/bin:$PATH

USER root
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then GO_ARCH="amd64"; \
    elif [ "$ARCH" = "arm64" ]; then GO_ARCH="arm64"; \
    else echo "Unsupported architecture: $ARCH"; exit 1; fi && \
    curl -fsSL https://go.dev/dl/go1.22.0.linux-${GO_ARCH}.tar.gz | tar -C /usr/local -xzf - && \
    mkdir -p /go/bin /go/pkg /go/src && \
    chmod -R a+w /go

USER project

LABEL description="Go language layer"
