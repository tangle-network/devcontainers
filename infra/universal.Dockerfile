FROM base-system:latest

ENV     GOROOT=/usr/local/go \
    GOPATH=/go \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    KOTLIN_HOME=/opt/kotlinc \
    PATH=/usr/local/go/bin:/go/bin:/usr/local/cargo/bin:/opt/kotlinc/bin:$PATH

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      default-jdk maven gradle php php-cli php-mbstring php-xml ruby ruby-dev unzip && \
    rm -rf /var/lib/apt/lists/*

USER project

USER root
RUN ARCH=$(dpkg --print-architecture) && if [ "$ARCH" = "amd64" ]; then GO_ARCH="amd64"; elif [ "$ARCH" = "arm64" ]; then GO_ARCH="arm64"; else echo "Unsupported architecture: $ARCH"; exit 1; fi && curl -fsSL https://go.dev/dl/go1.22.0.linux-${GO_ARCH}.tar.gz | tar -C /usr/local -xzf - && mkdir -p /go/bin /go/pkg /go/src && chmod -R a+w /go && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && chmod -R a+w $RUSTUP_HOME $CARGO_HOME && rustup component add rustfmt clippy rust-analyzer && \
    curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    gem install bundler && \
    KOTLIN_VERSION=$(curl -s https://api.github.com/repos/JetBrains/kotlin/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && curl -sL https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip -o kotlin.zip && unzip -q kotlin.zip -d /opt && rm kotlin.zip && chmod -R a+rx /opt/kotlinc && \
    pip3 install --no-cache-dir --break-system-packages poetry black mypy ruff pipx && \
    su - project -c 'go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest' && \
    su - project -c 'go install golang.org/x/tools/gopls@latest'

USER project

USER root
RUN npm install -g typescript ts-node @types/node eslint prettier nodemon dotenv
USER project

LABEL description="universal infrastructure layer"
