#!/usr/bin/env bash

# Create and set the password for the user account
[ -z "$RDP_USER" ] && RDP_USER=ubuntu
if ! id "$RDP_USER" >/dev/null 2>&1; then
    useradd --shell /bin/bash --uid 1020 --groups sudo --create-home "$RDP_USER"
    [ -z "$RDP_PASSWORD" ] && RDP_PASSWORD=ubuntu
    echo "$RDP_USER:$RDP_PASSWORD" | chpasswd
fi

# Remove existing sesman/xrdp PID files to prevent rdp sessions hanging on container restart
[ ! -f /var/run/xrdp/xrdp-sesman.pid ] || rm -f /var/run/xrdp/xrdp-sesman.pid
[ ! -f /var/run/xrdp/xrdp.pid ] || rm -f /var/run/xrdp/xrdp.pid

# Start xrdp sesman service
/usr/sbin/xrdp-sesman

# Run xrdp in foreground if no commands specified
if [ -z "$1" ]; then
    /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
