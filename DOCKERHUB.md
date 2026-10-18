# Seanime Docker

Community-maintained Docker images for [Seanime](https://seanime.app/), a self-hosted anime media server with a web interface.

## Quick start

```bash
docker run -d \
  --name seanime \
  --restart unless-stopped \
  -p 43211:43211 \
  -e SEANIME_SERVER_HOST=0.0.0.0 \
  -e PUID=1000 -e PGID=1000 \
  -v /path/to/seanime/config:/config \
  -v /path/to/your/anime:/anime \
  ethxn/seanime:latest
```

Open **http://localhost:43211**. Mount an existing anime library at `/anime`, and use `/config` for app data.

## Image tags

| Tag | Purpose |
| --- | --- |
| `latest` | Stable release |
| `<version>` | Pinned stable release (see published tags) |
| `canary` | Development build; may be unstable |
| `canary-<commit>` | Pinned development build (when published) |

Supports `linux/amd64` and `linux/arm64`.

## Transcoding

Jellyfin FFmpeg is included for software transcoding. NVIDIA NVENC, Intel QSV, and VAAPI encoders are included in the updated image, but hardware acceleration requires suitable host GPU drivers and Docker device access. NVIDIA encoding has been tested; Intel/AMD hardware execution is not yet verified.

See the [GPU setup guide](https://github.com/hawwwwwk/seanime-docker/blob/main/docs/hardware-acceleration.md) for NVIDIA and `/dev/dri` configuration.

## Configuration and installation guides

- [Complete Docker Compose setup and configuration](https://github.com/hawwwwwk/seanime-docker#quick-start-docker-compose)
- [Unraid installation](https://github.com/hawwwwwk/seanime-docker/blob/main/docs/unraid.md)
- [GPU passthrough and transcoding](https://github.com/hawwwwwk/seanime-docker/blob/main/docs/hardware-acceleration.md)
- [Issues and support](https://github.com/hawwwwwk/seanime-docker/issues)

For app-specific help see [upstream Seanime documentation](https://seanime.app/docs).
