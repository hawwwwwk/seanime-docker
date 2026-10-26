# Running Seanime on Unraid

[← Seanime Docker README](../README.md)

This guide covers the **Unraid-specific setup** for the community-maintained [`ethxn/seanime`](https://hub.docker.com/r/ethxn/seanime) image. Standard Docker users can follow the [main quick start](../README.md#quick-start-docker-compose) instead.

## Install

Seanime is available in your Unraid **Apps** tab. Select it, review the paths and variables, and install it. The template maintained in this repository is [`templates/seanime.xml`](../templates/seanime.xml).

Alternatively, if you really want, use **Docker → Add Container** to create an equivalent configuration manually using image `ethxn/seanime:latest`. 

## Container settings

| Setting | Recommended value | Notes |
| --- | --- | --- |
| Repository | `ethxn/seanime:latest` | Use a pinned tag when you need predictable upgrades. |
| Network | `bridge` | Default; choose another network only if needed. |
| Web UI port | Host `43211` → container `43211/tcp` | Change the host port if occupied. |
| Appdata | `/mnt/user/appdata/seanime` → `/config` | Persistent; writable. |
| Anime library | Your existing media share → `/anime` | Must be readable by the container user. |
| `SEANIME_SERVER_HOST` | `0.0.0.0` | Required for typical bridge networking. |
| `PUID` | `99` | Typical Unraid `nobody` user. |
| `PGID` | `100` | Typical Unraid `users` group. |

The provided template defaults to `PUID=99` and `PGID=100`. It changes ownership of `/config` at startup but **never recursively changes ownership of `/anime`**. Keep the appdata directory writable by the selected identity and avoid granting unnecessary write access to media.

Once running, open `http://<UNRAID-SERVER-IP>:43211` (or your chosen host port). In Seanime, select `/anime` as the media library location.

## GPU transcoding on Unraid

**No GPU required:** The container includes Jellyfin FFmpeg and supports software transcoding.

**NVIDIA:** Install/configure an Unraid-compatible NVIDIA driver and container runtime. Expose your GPU through the container's GPU settings or suitable Docker extra parameters, following your installed NVIDIA integration. The image requests the NVIDIA `video` driver capability by default, but it cannot provide the host driver or GPU by itself. For a `--gpus all` configuration, the Docker host must support GPU requests.

**Intel/AMD:** Expose `/dev/dri` to the container (for example, an appropriate Docker `--device=/dev/dri:/dev/dri` mapping) and ensure the Seanime user can access render/video devices. Device GIDs vary; use Docker supplementary groups instead of assuming Unraid's `PGID=100` is always sufficient.

Read the [hardware acceleration guide](hardware-acceleration.md) for commands and diagnostic checks.

## Troubleshooting

- **Web UI unreachable:** Check container logs, host port forwarding, and `SEANIME_SERVER_HOST=0.0.0.0`.
- **Config permission errors:** Verify the `/config` mapping and ownership for PUID/PGID. The container may adjust `/config` ownership on startup.
- **Anime library empty or inaccessible:** Confirm the host share mapping and read permissions. Use `/anime` during Seanime's setup (and in settings), not the Unraid host path.
- **Hardware transcoding fails:** Start with CPU transcoding to confirm basic playback, then verify GPU passthrough, device groups, and the selected hardware backend.

Container-specific problems: [seanime-docker issues](https://github.com/hawwwwwk/seanime-docker/issues). Application issues: [upstream Seanime](https://github.com/5rahim/seanime).
