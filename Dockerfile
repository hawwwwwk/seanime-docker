FROM node:22 AS frontend-builder

WORKDIR /app

COPY seanime-web/package.json seanime-web/package-lock.json ./seanime-web/

WORKDIR /app/seanime-web

RUN npm ci

COPY seanime-web/ /app/seanime-web/

RUN npm run build


FROM golang:1.26.2 AS server-builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

COPY --from=frontend-builder /app/seanime-web/out/ /app/web/

RUN go build -o seanime -trimpath -ldflags="-s -w"


FROM debian:13-slim AS runtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libc6 \
        libstdc++6 \
        libgcc-s1 \
        ffmpeg \
        fontconfig \
        fonts-noto-cjk \
        curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 seanime && \
    useradd --uid 1000 --gid seanime --create-home --shell /usr/sbin/nologin seanime

COPY --from=server-builder /app/seanime /app/seanime

WORKDIR /app

EXPOSE 43211

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl --fail --silent --show-error http://127.0.0.1:43211/ > /dev/null || exit 1

CMD ["/app/seanime", "--datadir=/config"]