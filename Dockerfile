# Build xrdp pulseaudio modules in builder container
# See https://github.com/neutrinolabs/pulseaudio-module-xrdp/wiki/README
ARG TAG=latest

FROM ubuntu:$TAG AS builder

# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        dpkg-dev \
        git \
        libpulse-dev \
        lsb-release \
        pulseaudio \
        sudo && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp && \
    /pulseaudio-module-xrdp/scripts/install_pulseaudio_sources_apt.sh

WORKDIR /pulseaudio-module-xrdp

RUN ./bootstrap && \
    ./configure PULSE_DIR=/root/pulseaudio.src && \
    make && \
    make install

# Build the final image
FROM ubuntu:$TAG

# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        git \
        gnupg \
        locales \
        pavucontrol \
        pulseaudio \
        pulseaudio-utils \
        software-properties-common \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme && \
    rm -rf /var/lib/apt/lists/*

# Add Mozilla Team PPA to install Firefox as the default snap package is not detected by XFCE4
# hadolint ignore=DL3008
RUN add-apt-repository -y ppa:mozillateam/ppa && \
    printf "Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n" > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends firefox && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

RUN locale-gen en_US.UTF-8 && \
    sed -i -E "s/^; autospawn =.*/autospawn = yes/" /etc/pulse/client.conf && \
    if [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ]; then \
        sed -i -E "s/^(autospawn=.*)/# \1/" /etc/pulse/client.conf.d/00-disable-autospawn.conf; \
    fi

COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/

COPY entrypoint.sh /usr/bin/entrypoint

EXPOSE 3389/tcp

ENTRYPOINT ["/usr/bin/entrypoint"]
