FROM --platform=$BUILDPLATFORM node:22 AS frontend-builder

WORKDIR /app

COPY seanime-web/package.json seanime-web/package-lock.json seanime-web/.npmrc ./seanime-web/

WORKDIR /app/seanime-web

RUN npm ci

COPY seanime-web/ /app/seanime-web/

RUN npm run build


FROM --platform=$BUILDPLATFORM golang:1.27.1 AS server-builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

COPY --from=frontend-builder /app/seanime-web/out/ /app/web/

RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -tags timetzdata -o seanime -trimpath -ldflags="-s -w"

    
FROM debian:trixie-slim AS runtime

ARG TARGETARCH
ARG JELLYFIN_FFMPEG_VERSION=7.1.4-3

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tzdata \
        util-linux; \
    curl -fSL \
        "https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v${JELLYFIN_FFMPEG_VERSION}/jellyfin-ffmpeg7_${JELLYFIN_FFMPEG_VERSION}-trixie_${TARGETARCH}.deb" \
        -o /tmp/jellyfin-ffmpeg.deb; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        /tmp/jellyfin-ffmpeg.deb; \
    ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/local/bin/ffmpeg; \
    ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/local/bin/ffprobe; \
    rm -rf /var/lib/apt/lists/* /tmp/jellyfin-ffmpeg.deb; \
    ffmpeg -hide_banner -encoders | grep -q h264_nvenc

COPY --from=server-builder /app/seanime /app/seanime
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PUID=1000 \
    PGID=1000 \
    NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

WORKDIR /app

EXPOSE 43211

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -fsS --max-time 5 http://127.0.0.1:43211/ > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/app/seanime", "--datadir=/config"]