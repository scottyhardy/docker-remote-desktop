FROM ubuntu:focal

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        ca-cacert \
        dbus-x11 \
        midori \
        x11-xserver-utils \
        xfce4 \
        xfce4-terminal \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1020 ubuntu \
    && useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd ubuntu) \
        --create-home --home-dir /home/ubuntu ubuntu

COPY entrypoint.sh /usr/bin/entrypoint
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]
