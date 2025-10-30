FROM go:latest

RUN go install github.com/gin-gonic/gin@latest

LABEL description="gin intermediate layer"
