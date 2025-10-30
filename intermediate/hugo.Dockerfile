FROM go:latest

USER root
RUN go install github.com/gohugoio/hugo@latest

USER project

LABEL description="hugo intermediate layer"
