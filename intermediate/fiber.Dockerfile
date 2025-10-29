FROM go:latest

RUN go install github.com/gofiber/fiber/v2@latest

LABEL description="fiber intermediate layer"
