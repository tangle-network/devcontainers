FROM go:latest

RUN go install github.com/labstack/echo/v4@latest

LABEL description="echo intermediate layer"
