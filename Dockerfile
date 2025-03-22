# Build xrdp pulseaudio modules in builder container
# See https://github.com/neutrinolabs/pulseaudio-module-xrdp/wiki/README
ARG TAG="bookworm-slim"

FROM debian:$TAG AS builder

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
FROM debian:$TAG

# hadolint ignore=DL3008
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        elementary-xfce-icon-theme \
        firefox-esr \
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
        xrdp && \
    rm -rf /var/lib/apt/lists/*

# Set locale and configure xrdp to start PulseAudio with XFCE
ENV LANG="en_US.UTF-8"
RUN locale-gen en_US.UTF-8 && \
    sed -i '2i /usr/bin/pulseaudio &' /etc/xrdp/startwm.sh

# Workaround for `systemctl --user` hanging on ARM64 architecture
# See https://github.com/scottyhardy/docker-remote-desktop/issues/42
RUN printf "#!/usr/bin/env bash\n\nif [ \"\$1\" = \"--user\" ]; then\n    echo \"Error: systemctl --user is not supported.\"\n    exit 1\nelse\n    exec /usr/bin/systemctl-original \"\$@\"\nfi\n" > /usr/bin/systemctl-wrapper && \
    chmod +x /usr/bin/systemctl-wrapper && \
    mv /usr/bin/systemctl /usr/bin/systemctl-original && \
    ln -s /usr/bin/systemctl-wrapper /usr/bin/systemctl

EXPOSE 3389/tcp

COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/
COPY entrypoint.sh /usr/bin/entrypoint

ENTRYPOINT ["/usr/bin/entrypoint"]
