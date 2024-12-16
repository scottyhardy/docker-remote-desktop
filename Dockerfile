# Build xrdp from UBUNTU 24.04 LTS
# See functions of the file: init.sh

ARG TAG=noble
FROM ubuntu:$TAG

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY ${DISPLAY:-:1}

RUN <<-EOF
    apt-get update
    apt-get upgrade -y
    apt-get install -y --no-install-recommends \
        apt-utils \
        dbus-x11 \
        locales \
        xorgxrdp \
        xrdp

	apt-get install -y --no-install-recommends \
        ca-certificates \
        chpasswd \
        curl \
        git \
        gnupg \
        lsb-release \
        mesa-utils \
        mesa-utils-extra \
        openssh-server \
        openssl \
        psmisc \
        sudo \
        vim \
        wget \
        x11-utils \
        x11-xserver-utils \
        xauth \
        xdg-utils \

    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# Firefox (snap fails)
RUN apt update && apt install -y wget && apt clean
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | tee /etc/apt/preferences.d/mozilla
RUN apt update && apt-get install -y firefox && apt clean

# OPTIONALLY ADDONS
RUN <<-EOF
	apt-get update
	apt-get install -y  --no-install-recommends \
        xfce4 \
        xfce4-goodies \
        xfce4-battery-plugin \
        xfce4-clipman-plugin \
        xfce4-cpufreq-plugin \
        xfce4-cpugraph-plugin \
        xfce4-datetime-plugin \
        xfce4-diskperf-plugin \
        xfce4-fsguard-plugin \
        xfce4-genmon-plugin \
        xfce4-indicator-plugin \
        xfce4-netload-plugin \
        xfce4-notifyd \
        xfce4-places-plugin \
        xfce4-sensors-plugin \
        xfce4-smartbookmark-plugin \
        xfce4-systemload-plugin \
        xfce4-taskmanager \
        xfce4-terminal \
        xfce4-timer-plugin \
        xfce4-verve-plugin \
        xfce4-weather-plugin \
        xfce4-whiskermenu-plugin \
        xubuntu-icon-theme
	apt-get clean

	sudo apt remove -y xfburn ristretto xfce4-dict
    sudo apt autoremove -y
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# Create a new user and add to the sudo group:
ENV USERNAME=demo
ARG PASSWORD=changeit
RUN useradd -ms /bin/bash ${USERNAME} && echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN usermod -aG sudo,xrdp ${USERNAME}
COPY xfce-config/.config /home/${USERNAME}
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Create a start script:
ENV entry=/usr/bin/entrypoint
RUN cat <<EOF > /usr/bin/entrypoint
#!/usr/bin/env bash
  sudo chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

  # Create the ubuntu account
  groupadd --gid 1020 ubuntu
  useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd ubuntu) --create-home --home-dir /home/ubuntu ubuntu
  usermod -aG sudo,xrdp ubuntu

  service dbus start
  service xrdp start
  tail -f /dev/null
EOF
RUN chmod +x /usr/bin/entrypoint

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]