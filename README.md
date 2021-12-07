# docker-remote-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)

Docker image with RDP server using [xrdp](http://xrdp.org) on Ubuntu with [XFCE](https://xfce.org).

Images are built weekly using the Ubuntu Docker image with the 'latest' tag.

## Running manually with `docker` commands

Download the latest version of the image:

```bash
docker pull scottyhardy/docker-remote-desktop
```

To run with an interactive bash session:

```bash
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    scottyhardy/docker-remote-desktop:latest /bin/bash
```

To start as a detached daemon:

```bash
docker run --detach \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    scottyhardy/docker-remote-desktop:latest
```

To stop the detached container:

```bash
docker kill remote-desktop
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

## Building docker-remote-desktop on your own machine

First, clone the GitHub repository:

```bash
git clone https://github.com/scottyhardy/docker-remote-desktop.git

cd docker-remote-desktop
```

You can then build the image with the supplied script:

```bash
./build
```

Or run the following `docker` command:

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
