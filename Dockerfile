FROM --platform=$BUILDPLATFORM node:22.23.4 AS frontend-builder

WORKDIR /app

COPY seanime-web/package.json seanime-web/package-lock.json seanime-web/.npmrc ./seanime-web/

WORKDIR /app/seanime-web

RUN npm ci

COPY seanime-web/ /app/seanime-web/

RUN npm run build


FROM --platform=$BUILDPLATFORM golang:1.27.3 AS server-builder

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

# Check the toolchain embedded in the compiled binary, including cross-built binaries.
RUN go version -m /app/seanime | grep -Fq 'go1.27.3'


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
    ca_version="$(dpkg-query -W -f='${Version}' ca-certificates)"; \
    if ! dpkg --compare-versions "$ca_version" ge '20250419+deb13u1'; then \
        echo "ERROR: ca-certificates $ca_version is older than the security-fixed version" >&2; \
        exit 1; \
    fi; \
    echo "Verified ca-certificates version: $ca_version"; \
    curl --fail --show-error --silent --location --retry 3 \
        "https://github.com/jellyfin/jellyfin-ffmpeg/releases/download/v${JELLYFIN_FFMPEG_VERSION}/jellyfin-ffmpeg7_${JELLYFIN_FFMPEG_VERSION}-trixie_${TARGETARCH}.deb" \
        -o /tmp/jellyfin-ffmpeg.deb; \
    case "$TARGETARCH" in \
        amd64) ffmpeg_sha256='8e30f9f7f3958c524bec8334540e4241145ad4300b328a08a55783c619187225' ;; \
        arm64) ffmpeg_sha256='a8fa3ec7cf8fbaf06bb4fdb768d4dd7798277fe4c4b66884c777dc7d575877fb' ;; \
        *) echo "ERROR: unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    printf '%s  %s\n' "$ffmpeg_sha256" /tmp/jellyfin-ffmpeg.deb | sha256sum --check --status; \
    echo "Verified jellyfin-ffmpeg ${JELLYFIN_FFMPEG_VERSION} ($TARGETARCH) SHA-256"; \
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