#!/bin/sh
set -eu

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

# PUID and PGID must be numeric.
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

# Runtime permission setup requires root.
if [ "$(id -u)" = "0" ]; then

    CURRENT_UID="$(id -u seanime)"
    CURRENT_GID="$(id -g seanime)"

    # Change the Seanime UID if necessary.
    if [ "$CURRENT_UID" != "$PUID" ]; then
        if getent passwd "$PUID" >/dev/null 2>&1; then
            echo "ERROR: PUID $PUID is already in use inside the container." >&2
            exit 1
        fi

        usermod -u "$PUID" seanime
    fi

    # Change the primary group.
    #
    # The requested GID may already exist. This is important for Unraid,
    # where PGID 100 is commonly used and Debian already has GID 100.
    if [ "$CURRENT_GID" != "$PGID" ]; then
        if getent group "$PGID" >/dev/null 2>&1; then
            usermod -g "$PGID" seanime
        else
            groupmod -g "$PGID" seanime
            usermod -g "$PGID" seanime
        fi
    fi

    # Seanime owns its application data.
    mkdir -p /config
    chown -R "$PUID:$PGID" /config

    # Never change ownership of /anime.
    export HOME=/home/seanime

    exec gosu seanime "$@"
fi

# If the container was explicitly started as another user, just run as-is.
exec "$@"