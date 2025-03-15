#!/usr/bin/env bash

if [ "$1" = "--user" ]; then
    echo "Error: systemctl --user is not supported."
    exit 1
else
    exec /usr/bin/systemctl-original "$@"
fi
