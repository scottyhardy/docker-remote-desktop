# Build xrdp from UBUNTU 24.04 LTS
# See functions of the file: init.sh

ARG TAG=noble
FROM ubuntu:$TAG

RUN <<-EOF
    apt-get update
    apt-get upgrade -y
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        dbus-x11 \
        git \
        locales \
        sudo \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme
    sudo apt remove -y xfburn ristretto xfce4-dict
    sudo apt autoremove -y
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<-EOF
	apt-get update
	DEBIAN_FRONTEND="noninteractive" apt-get install -y \
		ca-certificates \
		gnupg \
		lsb-release \
		openssh-server \
		openssl \
		xauth \
	    curl \
	    git \
	    lsb-release \
	    vim chpasswd \
	    wget
	apt-get clean
EOF

# Firefox (snap fails)
RUN apt update && apt install -y wget && apt clean
RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | tee /etc/apt/preferences.d/mozilla
RUN apt update && apt-get install -y firefox && apt clean

# Create a new user and add to the sudo group:
ENV USERNAME=demo
ARG PASSWORD=changeit
RUN useradd -ms /bin/bash ${USERNAME} && echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN usermod -aG sudo,xrdp ${USERNAME}

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