# Seanime Docker

[![Docker pulls](https://img.shields.io/docker/pulls/ethxn/seanime?logo=docker&label=Docker%20pulls)](https://hub.docker.com/r/ethxn/seanime)
[![CI](https://github.com/hawwwwwk/seanime-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/hawwwwwk/seanime-docker/actions/workflows/ci.yml)
[![Architectures](https://img.shields.io/badge/linux-amd64%20%7C%20arm64-blue)](https://hub.docker.com/r/ethxn/seanime/tags)

A community-maintained, multi-architecture Docker image for [Seanime](https://seanime.app/), a self-hosted anime media server. Run the Seanime web interface with persistent application data, configurable user permissions, and bundled Jellyfin FFmpeg for transcoding.

> **Unofficial image.** This Docker distribution is maintained independently of the upstream [Seanime project](https://github.com/5rahim/seanime). For Seanime application features and support, refer to [upstream documentation](https://seanime.app/docs).

**Image:** [`ethxn/seanime`](https://hub.docker.com/r/ethxn/seanime)  
**Platforms:** `linux/amd64`, `linux/arm64`

## Quick start (Docker Compose)

Create a `compose.yaml`:

```yaml
services:
  seanime:
    image: ethxn/seanime:latest
    container_name: seanime
    restart: unless-stopped
    ports:
      - "43211:43211"
    environment:
      SEANIME_SERVER_HOST: "0.0.0.0"
      PUID: "1000"
      PGID: "1000"
    volumes:
      - ./config:/config
      - /path/to/your/anime:/anime
```

Replace `/path/to/your/anime` with the absolute path to your library. Then start the container:

```bash
docker compose up -d
```

Open **http://localhost:43211**, or replace `localhost` with the Docker host's IP address. Point Seanime's library scanner at `/anime` when setting up Seanime.

The image does not include anime files; supply your own library. If you only need scanning and playback, you can mount the library read-only (`/path/to/your/anime:/anime:ro`). Use a writable mount if you want Seanime to modify files.

### Docker CLI

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

## Image tags

| Tag | Description |
| --- | --- |
| `latest` | Latest published stable Seanime image. |
| `<version>` (for example, `3.10.3`) | Version-pinned stable image, when published. |
| `canary` | Latest published development build; may contain breaking changes. |
| `canary-<commit>` | Commit-pinned canary image, when published. |

See [Docker Hub tags](https://hub.docker.com/r/ethxn/seanime/tags) for the actual available versions.

## Configuration

| Setting | Default | Purpose |
| --- | --- | --- |
| `43211/tcp` | — | Seanime web interface. Map a host port to container port `43211`. |
| `/config` | — | Persistent database, settings, and application data. Must be writable. |
| `/anime` | — | Your media library. Read-only access is enough for scanning and playback. |
| `SEANIME_SERVER_HOST` | `0.0.0.0` in examples | Listen on all container interfaces, so Docker port forwarding works. |
| `PUID` | `1000` | UID used to run Seanime after startup. |
| `PGID` | `1000` | Primary GID used to run Seanime after startup. |

At startup, the entrypoint adjusts ownership of `/config` and runs Seanime with the configured UID/GID. It **does not change ownership of `/anime`**. Make sure the selected user can read your media library and write to `/config`.

Other media paths, such as downloads, can be mounted separately and configured in Seanime as needed. Docker `--group-add` or Compose `group_add` is supported for supplementary device-access groups.

## Transcoding and hardware acceleration

[Jellyfin FFmpeg](https://github.com/jellyfin/jellyfin-ffmpeg) is bundled; **software transcoding requires no FFmpeg installation on the host**.

The image includes FFmpeg encoders for NVIDIA NVENC, Intel Quick Sync Video (QSV), and VAAPI, but using them requires suitable GPU hardware, host drivers, and Docker device access. The container alone cannot enable host GPU acceleration.

- **NVIDIA:** Pass GPUs into Docker (for example, `--gpus all`) and configure the NVIDIA runtime/toolkit on the host.
- **Intel / AMD:** Pass `/dev/dri` into the container and grant the container user access to the relevant device groups.
- **No GPU:** CPU transcoding remains available.

See the [hardware acceleration guide](docs/hardware-acceleration.md) for setup examples and troubleshooting.

## Other installation guides

- [Unraid](docs/unraid.md) - Community Applications/template setup, paths, IDs, and GPU passthrough.
- [Hardware acceleration](docs/hardware-acceleration.md) - NVIDIA, QSV, VAAPI, and permission considerations.
- [Docker Hub image](https://hub.docker.com/r/ethxn/seanime) - published tags and pulls.

## Support and attribution

For container-specific problems, [open an issue here](https://github.com/hawwwwwk/seanime-docker/issues). For Seanime application bugs or feature requests, use the [upstream project](https://github.com/5rahim/seanime).

Seanime and this Docker distribution are separate projects. See the repository [LICENSE](LICENSE) and the upstream Seanime repository for attribution and licensing information.

### AI disclosure

Documentation and container implementation work have included AI assistance (ChatGPT). All code changes and documentation is looked over manually before publishing and tested locally on my own hardware.
