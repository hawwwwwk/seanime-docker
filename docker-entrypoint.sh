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

    # Preserve Docker-assigned supplementary groups, excluding root (GID 0)
    # and the primary GID, which setpriv assigns separately.
    extra_groups=""
    for gid in $(id -G); do
        case "$gid" in
            0|"$PGID") continue ;;
        esac
        extra_groups="${extra_groups:+$extra_groups,}$gid"
    done

    if [ -n "$extra_groups" ]; then
        exec setpriv --reuid="$PUID" --regid="$PGID" \
            --groups="$extra_groups" -- "$@"
    fi

    exec setpriv --reuid="$PUID" --regid="$PGID" \
        --clear-groups -- "$@"
fi

exec "$@"