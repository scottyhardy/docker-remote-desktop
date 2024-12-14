# Build xrdp from UBUNTU 24.04 LTS
# See functions of the file: init.sh

ARG TAG=noble
FROM ubuntu:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
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
	  git wget curl lsb-release dbus dbus-x11 vim chpasswd \
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

RUN <<-EOF
	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get install -y --no-install-recommends -o APT::Immediate-Configure=0 \
		at-spi2-core \
		ca-certificates \
		catatonit \
		curl \
		dbus \
		dbus-x11 \
		gnupg \
		libbz2-1.0 \
		libegl1 \
		libepoxy0 \
		libfdk-aac2 \
		libfreetype6 \
		libfuse2t64 \
		libgbm1 \
		libgl1 \
		libgl1-mesa-dri \
		libgles2 \
		libglu1 \
		libglvnd0 \
		libglx-mesa0 \
		libmp3lame0 \
		libopus0 \
		libpam0g \
		libpixman-1-0 \
		libpulse0 \
		libssl3t64 \
		libsystemd0 \
		libx11-6 \
		libx11-xcb1 \
		libxcb-glx0 \
		libxcb-keysyms1 \
		libxcb1 \
		libxext6 \
		libxfixes3 \
		libxml2 \
		libxrandr2 \
		libxt6t64 \
		libxtst6 \
		libxv1 \
		locales \
		lsb-release \
		mesa-opencl-icd \
		mesa-va-drivers \
		mesa-vdpau-drivers \
		mesa-vulkan-drivers \
		ocl-icd-opencl-dev \
		openssh-server \
		openssl \
		perl-base \
		policykit-1 \
		pulseaudio \
		runit \
		tzdata \
		udev \
		xauth \
		xkb-data \
		xserver-xorg-core \
		xserver-xorg-input-evdev \
		xserver-xorg-input-joystick \
		xserver-xorg-input-libinput \
		xserver-xorg-video-dummy \
		xserver-xorg-video-fbdev \
		xserver-xorg-video-vesa \
		zlib1g \
	&& apt-get clean
EOF

# Firefox (snap fails)
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | tee /etc/apt/preferences.d/mozilla
RUN apt update && apt-get install -y firefox && apt-get clean

### install chrome
# RUN apt-get update && apt-get install -y wget && apt-get install -y zip
# RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

# Create a new user and add to the sudo group:
ENV USERNAME=demo
ARG PASSWORD=changeit
RUN useradd -ms /bin/bash ${USERNAME} && echo "${USERNAME}:${PASSWORD}" | chpasswd
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