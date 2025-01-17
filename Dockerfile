# Build xrdp pulseaudio modules in builder container
# See https://github.com/neutrinolabs/pulseaudio-module-xrdp/wiki/README
ARG TAG=latest

FROM ubuntu:$TAG as builder

RUN [ -f /etc/apt/sources.list.d/ubuntu.sources ] \
    && sed -i -E 's/^(Types: deb|# deb-src )/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources \
    || sed -i -E 's/^# deb-src /deb-src /g' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        dpkg-dev \
        git \
        libpulse-dev \
        lsb-release \
        pulseaudio \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp \
    && /pulseaudio-module-xrdp/scripts/install_pulseaudio_sources_apt.sh

WORKDIR /pulseaudio-module-xrdp

RUN ./bootstrap \
    && ./configure PULSE_DIR=/root/pulseaudio.src \
    && make \
    && make install


# Build the final image
FROM ubuntu:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        firefox \
        git \
        locales \
        pavucontrol \
        pulseaudio \
        pulseaudio-utils \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf \
    && [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ] && sed -i -E 's/^(autospawn=.*)/# \1/' /etc/pulse/client.conf.d/00-disable-autospawn.conf || : \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/

COPY entrypoint.sh /usr/bin/entrypoint

EXPOSE 3389/tcp

ENTRYPOINT ["/usr/bin/entrypoint"]
