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

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /tmp/pulseaudio-module-xrdp
WORKDIR /tmp/pulseaudio-module-xrdp
RUN ./scripts/install_pulseaudio_sources_apt.sh && \
    ./bootstrap && \
    ./configure PULSE_DIR=/root/pulseaudio.src && \
    make && \
    make install DESTDIR=/tmp/install

# Build the final image
FROM debian:$TAG AS final

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

# Set locale
ENV LANG="en_US.UTF-8"
RUN locale-gen en_US.UTF-8

# Workaround for `systemctl --user` hanging on ARM64 architecture
# See https://github.com/scottyhardy/docker-remote-desktop/issues/42
RUN echo "#!/usr/bin/env bash" > /usr/bin/systemctl-wrapper && \
    echo "if [ \"\$1\" = \"--user\" ]; then" >> /usr/bin/systemctl-wrapper && \
    echo "    echo \"Error: systemctl --user is not supported.\"" >> /usr/bin/systemctl-wrapper && \
    echo "    exit 1" >> /usr/bin/systemctl-wrapper && \
    echo "else" >> /usr/bin/systemctl-wrapper && \
    echo "    exec /usr/bin/systemctl-original \"\$@\"" >> /usr/bin/systemctl-wrapper && \
    echo "fi" >> /usr/bin/systemctl-wrapper && \
    chmod +x /usr/bin/systemctl-wrapper && \
    mv /usr/bin/systemctl /usr/bin/systemctl-original && \
    ln -s /usr/bin/systemctl-wrapper /usr/bin/systemctl

# Configure pulseaudio for xrdp
COPY --from=builder /tmp/install/ /
RUN sed -i 's|^Exec=.*|Exec=/usr/bin/pulseaudio|' /etc/xdg/autostart/pulseaudio-xrdp.desktop

EXPOSE 3389/tcp

COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
