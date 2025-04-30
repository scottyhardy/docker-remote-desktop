# docker-remote-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)
[![GitHub stars](https://img.shields.io/github/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/scottyhardy/docker-remote-desktop.svg?style=social)](https://github.com/scottyhardy/docker-remote-desktop/network)
[![Docker Stars](https://img.shields.io/docker/stars/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)
[![Docker Pulls](https://img.shields.io/docker/pulls/scottyhardy/docker-remote-desktop.svg?style=social)](https://hub.docker.com/r/scottyhardy/docker-remote-desktop)

Docker image with RDP server using [xrdp](https://www.xrdp.org) on Ubuntu with [Xfce](https://xfce.org).

Images are built weekly using Ubuntu 24.04 (noble).

## Getting Started

Run with an interactive bash session:

```bash
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    scottyhardy/docker-remote-desktop:latest /bin/bash
```

Start as a detached daemon:

```bash
docker run --detach \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    scottyhardy/docker-remote-desktop:latest
```

Stop the detached container:

```bash
docker kill remote-desktop
```

Download the latest version of the image:

```bash
docker pull scottyhardy/docker-remote-desktop
```

You can also customize the password and even the username, which primarily involves two environment variables:

- `RDP_USER`  
The RDP login username, default is "ubuntu".
- `RDP_PASSWORD`  
The RDP login password, default is "ubuntu".

An example of setting the username to `user` and the password to `password`:

```bash
docker run --detach \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --env RDP_USER=user \
    --env RDP_PASSWORD=password \
    --name="remote-desktop" \
    scottyhardy/docker-remote-desktop:latest
```

## Connecting with an RDP client

All Windows desktops and servers come with Remote Desktop pre-installed and macOS users can download the Microsoft Remote Desktop application for free from the App Store.  For Linux users, I'd suggest using the Remmina Remote Desktop client.

For the hostname, use `localhost` if the container is hosted on the same machine you're running your Remote Desktop client on and for remote connections just use the name or IP address of the machine you are connecting to.
NOTE: To connect to a remote machine, it will require TCP port 3389 to be exposed through the firewall.

To log in, use the following default user account details:

```bash
Username: ubuntu
Password: ubuntu
```

![Screenshot of login prompt](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_1.png)

![Screenshot of XFCE desktop](https://raw.githubusercontent.com/scottyhardy/docker-remote-desktop/master/screenshot_2.png)

## Building docker-remote-desktop

Clone the GitHub repository:

```bash
git clone https://github.com/scottyhardy/docker-remote-desktop.git
cd docker-remote-desktop
```

Build the image with the supplied script:

```bash
./build
```

Or run the following docker command:

```bash
docker build -t docker-remote-desktop .
```

## Running local images with scripts

I've created some simple scripts that give the minimum requirements for either running the container interactively or running as a detached daemon.

To run with an interactive bash session:

```bash
./run
```

To start as a detached daemon:

```bash
./start
```

To stop the detached container:

```bash
./stop
```
