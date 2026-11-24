FROM alpine:3.19

RUN apk add --no-cache bash python3 py3-pip

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY scripts/ /app/scripts/
COPY requirements.txt /app/ 2>/dev/null || true

RUN chown -R appuser:appgroup /app

# USER appuser

ENTRYPOINT ["bash", "/app/scripts/main.sh"]
