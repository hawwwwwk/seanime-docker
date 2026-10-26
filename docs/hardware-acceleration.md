# Hardware acceleration

[← Seanime Docker README](../README.md)

The container bundles [Jellyfin FFmpeg](https://github.com/jellyfin/jellyfin-ffmpeg) for CPU transcoding and includes hardware encoders such as NVIDIA NVENC, Intel Quick Sync Video (QSV), and VAAPI. Actual GPU transcoding depends on device access and Seanime's transcoding settings.

## CPU (no GPU)

No hardware passthrough or additional host FFmpeg installation is needed. Use the [standard Compose example](../README.md#quick-start-docker-compose) and select software transcoding in Seanime.

## NVIDIA (NVENC)

**Requirements:** A compatible NVIDIA GPU, working host drivers, and a Docker runtime configured for NVIDIA GPU access (normally NVIDIA Container Toolkit on Linux; GPU support depends on the host platform).

For `docker run`, add `--gpus all`. Example:

```bash
docker run -d \
  --name seanime \
  --restart unless-stopped \
  --gpus all \
  -p 43211:43211 \
  -e SEANIME_SERVER_HOST=0.0.0.0 \
  -e PUID=1000 -e PGID=1000 \
  -v /path/to/seanime/config:/config \
  -v /path/to/your/anime:/anime \
  ethxn/seanime:latest
```

Alternatively, supported modern Docker Compose versions allow `gpus: all` on the service. The image sets `NVIDIA_DRIVER_CAPABILITIES=compute,video,utility` by default; you still need to grant GPU access through Docker's settings.

Check GPU visibility:

```bash
docker exec seanime nvidia-smi
```

In Seanime, enable transcoding and select NVIDIA hardware acceleration. Confirm playback uses the transcoding player rather than direct play. Seanime logs can show `hardware acceleration resolved backend=nvidia`.

## Intel QSV and Intel/AMD VAAPI (Linux)

**Requirements:** Exposed Linux render nodes (usually `/dev/dri/renderD*`), compatible host drivers, and appropriate container user permissions.

Example Compose additions:

```yaml
services:
  seanime:
    devices:
      - /dev/dri:/dev/dri
    # If required, add the numeric GIDs that own your /dev/dri devices:
    # group_add:
    #   - "109"
```

These are **additions** to the main Compose example, not a complete Compose file. Replace the sample GID with the one on your host; don't assume `109` is correct.

Inspect the host render device ownership:

```bash
ls -ln /dev/dri/
```

If the render node is owned by a supplementary group your PUID/PGID doesn't belong to, add that **numeric** GID using Compose `group_add` (or Docker `--group-add`). The entrypoint preserves supplementary groups across the privilege drop. If there is no render node or compatible driver, simply mounting `/dev/dri` may not be sufficient.

In Seanime, choose Intel/QSV or VAAPI acceleration as appropriate for your hardware and monitor logs during playback.

## Diagnostics

List installed encoders (capability listing only):

```bash
docker exec seanime ffmpeg -hide_banner -encoders
```

Check Seanime logs for hardware selection or FFmpeg errors:

```bash
docker logs seanime 2>&1 | grep -Ei 'hardware acceleration|nvenc|vaapi|qsv|ffmpeg|transcod|error'
```

If hardware transcoding fails, verify that CPU transcoding works first, then check GPU visibility, device access, permissions, and that Seanime is actually set to **transcode** (not direct play).

Please report issues with your host OS, GPU model, Docker flags, Seanime hardware setting, and relevant log excerpts in [seanime-docker issues](https://github.com/hawwwwwk/seanime-docker/issues).
