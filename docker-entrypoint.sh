#!/bin/sh
set -eu

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

case "$PUID" in
    ''|*[!0-9]*)
        echo "ERROR: PUID must be a numeric UID." >&2
        exit 1
        ;;
esac

case "$PGID" in
    ''|*[!0-9]*)
        echo "ERROR: PGID must be a numeric GID." >&2
        exit 1
        ;;
esac

if [ "$(id -u)" = "0" ]; then
    mkdir -p /config /home/seanime

    chown -R "$PUID:$PGID" /config
    chown "$PUID:$PGID" /home/seanime

    # Never change ownership of /anime.
    export HOME=/home/seanime

    exec su-exec "$PUID:$PGID" "$@"
fi

exec "$@"