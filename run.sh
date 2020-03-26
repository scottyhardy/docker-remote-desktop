#!/usr/bin/env bash

docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    docker-xrdp-xfce:latest "$@"