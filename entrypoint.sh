#!/usr/bin/env bash

# Run xrdp as daemon
/usr/sbin/xrdp

exec "$@"
#exec gosu ubuntu "$@"
