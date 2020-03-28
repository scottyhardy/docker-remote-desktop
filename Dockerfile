# Build xrdp pulseaudio modules in builder container
# See https://github.com/neutrinolabs/pulseaudio-module-xrdp/wiki/README
FROM ubuntu:focal as builder
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        dpkg-dev \
        git \
        libpulse-dev \
        pulseaudio \
    && apt-get build-dep -y pulseaudio \
    && apt-get source pulseaudio \
    && rm -rf /var/lib/apt/lists/*

RUN cd /pulseaudio-$(pulseaudio --version | awk '{print $2}') \
    && ./configure

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp \
    && cd /pulseaudio-module-xrdp \
    && ./bootstrap \
    && ./configure PULSE_DIR=/pulseaudio-$(pulseaudio --version | awk '{print $2}') \
    && make \
    && make install \
    && rm -f /usr/lib/pulse-*/modules/module-xrdp-sink.la /usr/lib/pulse-*/modules/module-xrdp-source.so

# Build the final image
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

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        pulseaudio-utils \
        xfce4-pulseaudio-plugin \
        pavucontrol \
        pulseaudio \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/lib/pulse-*/modules /usr/lib/pulse-*/modules
COPY entrypoint.sh /usr/bin/entrypoint
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]
