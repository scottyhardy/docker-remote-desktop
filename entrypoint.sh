#!/usr/bin/env bash

# Create the user account
groupadd --gid 1020 user
useradd --shell /bin/bash --uid 1020 --gid 1020 --groups sudo --password "$(openssl passwd user)" --create-home --home-dir /home/user user

# Start xrdp sesman service
/usr/sbin/xrdp-sesman

# Run xrdp in foreground if no commands specified
if [ -z "$1" ]; then
    exec /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
