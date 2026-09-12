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

RUN CGO_ENABLED=0 go build -tags timetzdata -o seanime -trimpath -ldflags="-s -w"


FROM alpine:3.23 AS runtime

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    su-exec \
    jellyfin-ffmpeg \
    --repository=https://repo.jellyfin.org/releases/alpine/ && \
    ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin/ffmpeg && \
    ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin/ffprobe

COPY --from=server-builder /app/seanime /app/seanime
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PUID=1000 \
    PGID=1000

WORKDIR /app

EXPOSE 43211

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget -q -t 1 --spider http://127.0.0.1:43211/ || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/app/seanime", "--datadir=/config"]