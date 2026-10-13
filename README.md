<h2>Docker / Unraid</h2>

[![Docker Pulls](https://img.shields.io/docker/pulls/ethxn/seanime?logo=docker&label=pulls)](https://hub.docker.com/r/ethxn/seanime)
[![CI](https://github.com/hawwwwwk/seanime-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/hawwwwwk/seanime-docker/actions/workflows/ci.yml)
[![Seanime Release](https://img.shields.io/github/v/release/5rahim/seanime?label=Seanime%20release&logo=github)](https://github.com/5rahim/seanime/releases/latest)
[![Architectures](https://img.shields.io/badge/architectures-amd64%20%7C%20arm64-blue?logo=docker)](https://hub.docker.com/r/ethxn/seanime/tags)

<p>
  This repository also builds a Docker image for running Seanime as a self-hosted container, with support for Unraid.
</p>

<blockquote>
  <p>
    This Docker image is community-maintained and is not an official Seanime container.
  </p>
</blockquote>

<h3>Docker image</h3>

<pre><code>ethxn/seanime:latest</code></pre>

<p>A version-pinned image is also available:</p>

<pre><code>ethxn/seanime:3.10.3</code></pre>

<p>
  The image currently packages Seanime 3.10.3-Saisei.
</p>

<h3>Canary image</h3>

<p>This project also packages the latest Seanime canary app versions:</p>

<pre><code>ethxn/seanime:canary</code></pre>

<p>Pinned:</p>

<pre><code>ethxn/seanime:canary-3e03b73b</code></pre>

<h3>Container configuration</h3>

<table>
  <thead>
    <tr>
      <th>Setting</th>
      <th>Container value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Web UI</td>
      <td><code>43211/tcp</code></td>
    </tr>
    <tr>
      <td>Application data</td>
      <td><code>/config</code></td>
    </tr>
    <tr>
      <td>Anime library</td>
      <td><code>/anime</code></td>
    </tr>
    <tr>
      <td>Server bind address</td>
      <td><code>SEANIME_SERVER_HOST=0.0.0.0</code></td>
    </tr>
    <tr>
      <td>User ID</td>
      <td><code>PUID=1000</code></td>
    </tr>
    <tr>
      <td>Group ID</td>
      <td><code>PGID=1000</code></td>
    </tr>
  </tbody>
</table>

<p>
  Application data stored under <code>/config</code> is persistent and should be mapped to a host directory.
</p>

<p>
  The container runs Seanime as the user and group specified by <code>PUID</code> and <code>PGID</code>.
  These default to <code>1000:1000</code>. The container adjusts ownership of <code>/config</code>
  at startup, but never changes ownership of files under <code>/anime</code>.
</p>

<p>Example:</p>

<pre><code>docker run -d \
  --name Seanime \
  -p 43211:43211 \
  -e SEANIME_SERVER_HOST=0.0.0.0 \
  -e PUID=1000 \
  -e PGID=1000 \
  -v /path/to/seanime/config:/config \
  -v /path/to/anime:/anime \
  ethxn/seanime:latest
</code></pre>

<h3>Unraid</h3>

<p>
  An Unraid Docker template is included with this repository.
</p>

<p>Recommended mappings:</p>

<pre><code>/mnt/user/appdata/seanime -> /config
/path/to/your/anime       -> /anime
</code></pre>

<p>
  The Unraid template defaults to <code>PUID=99</code> and <code>PGID=100</code>,
  matching Unraid's typical <code>nobody:users</code> ownership.
</p>

<p>The WebUI is available at:</p>

<pre><code>http://&lt;UNRAID-IP&gt;:43211</code></pre>

<h3>Media transcoding</h3>

<p>
  Jellyfin FFmpeg is included in the container, so software transcoding works without installing FFmpeg on the host.
</p>

<p>
  Hardware acceleration is optional and depends on the Docker host configuration.
  GPU devices and appropriate host drivers or runtimes must be made available to the container separately.
</p>

## AI Disclosure

- Tool(s) used: ChatGPT
- What AI was used for: Non-unraid & Unraid Docker instructions, boilerplate, and formatting.
- How you verified the change fits Seanime's architecture: Instructions were all tested and verified to work on a local Unraid server and Docker host.
