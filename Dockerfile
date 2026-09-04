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
        fonts-noto-cjk && \
    rm -rf /var/lib/apt/lists/*

COPY --from=server-builder /app/seanime /app/seanime

WORKDIR /app

EXPOSE 43211

CMD ["/app/seanime", "--datadir=/config"]