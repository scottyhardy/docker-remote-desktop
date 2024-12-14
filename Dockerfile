# Build xrdp from UBUNTU 24.04 LTS
# See functions of the file: init.sh

ARG TAG=noble
FROM ubuntu:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        firefox \
        git \
        locales \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN <<-EOF
	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get install -y --no-install-recommends -o APT::Immediate-Configure=0 \
	  git curl lsb-release dbus dbus-x11 vim chpasswd \
      xfce4-clipman-plugin \
      xfce4-cpufreq-plugin \
      xfce4-cpugraph-plugin \
      xfce4-diskperf-plugin \
      xfce4-datetime-plugin \
      xfce4-fsguard-plugin \
      xfce4-genmon-plugin \
      xfce4-indicator-plugin \
      xfce4-netload-plugin \
      xfce4-places-plugin \
      xfce4-sensors-plugin \
      xfce4-smartbookmark-plugin \
      xfce4-systemload-plugin \
      xfce4-timer-plugin \
      xfce4-verve-plugin \
      xfce4-weather-plugin
   apt-get clean
EOF

# Firefox (snap fails)
# RUN wget -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
# RUN tar xjf /tmp/firefox.tar.bz2 && sudo ln -s /firefox/firefox /usr/bin/firefox

### install chrome
# RUN apt-get update && apt-get install -y wget && apt-get install -y zip
# RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

# Create a new user and add to the sudo group
# ENV USERNAME=demo
# ARG PASSWORD=changeit
# RUN useradd -m -s /bin/bash ${USERNAME} && echo "${USERNAME}:${PASSWORD}" | chpasswd && adduser ${USERNAME} sudo

# Create a new user and add to the sudo group:
ENV USERNAME=demo
ARG PASSWORD=changeit
RUN useradd -m -s /bin/bash demo && echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN usermod -aG sudo,xrdp,ssl-cert ${USERNAME}

# Create a start script:
ENV entry=/usr/bin/entrypoint
RUN cat <<EOF > /usr/bin/entrypoint
#!/usr/bin/env bash
  # Create the user account
  groupadd --gid 1020 ubuntu
  useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd ubuntu) --create-home --home-dir /home/ubuntu ubuntu
  # useradd --shell /bin/bash --uid 1020 --gid 1020 --password ubuntu --create-home --home-dir /home/ubuntu ubuntu
  # echo "ubuntu:ubuntu" | chpasswd
  usermod -aG sudo ubuntu

  # Start xrdp sesman service
  /usr/sbin/xrdp-sesman

  service dbus start
  service xrdp start
  tail -f /dev/null
EOF
RUN chmod +x /usr/bin/entrypoint

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]