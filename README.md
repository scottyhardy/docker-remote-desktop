# docker-remote-desktop

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)

Docker container image with RDP server using [Xrdp](http://xrdp.org) running on Ubuntu with [XFCE](https://xfce.org).

Container images are built weekly using the latest and previous Ubuntu LTS versions. Use the `previous-lts` tag to access the previous LTS version.

## Getting Started

Run with an interactive bash session:

```bash
docker run -it \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    --shm-size="1g" \
    scottyhardy/docker-remote-desktop:latest /bin/bash
```

Start the container as a detached daemon:

```bash
docker run --detach \
    --rm \
    --hostname="$(hostname)" \
    --publish="3389:3389/tcp" \
    --name="remote-desktop" \
    --shm-size="1g" \
    scottyhardy/docker-remote-desktop:latest
```

Stop the detached container:

```bash
docker kill remote-desktop
```

Download the latest docker-remote-desktop container image:

```bash
docker pull scottyhardy/docker-remote-desktop
```

## Connecting with a Remote Desktop client

Once docker-remote-desktop is running, you will need a Remote Desktop client to connect.

- Windows: Remote Desktop Connection is pre-installed on all Windows desktops and servers.
- macOS: The Microsoft Remote Desktop application can be downloaded for free from the App Store.
- Linux: The Remmina Remote Desktop client is recommended. You can find installation instructions on the [Remmina website](https://remmina.org/how-to-install-remmina/).

Use `localhost` as the hostname if the container is running on the same machine as your Remote Desktop client. For remote connections, use the hostname or IP address of the machine running the container. Ensure that TCP port 3389 is open on the firewall of the host machine.

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

## Running locally built container with scripts

These simple scripts are provided to run the local container image built in the previous step, either interactively or as a detached daemon. Note that these scripts do not download the image from Docker Hub.

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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
