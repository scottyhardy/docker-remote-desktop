# ubuntu-docker-desktop-xrdp

[![build](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml/badge.svg)](https://github.com/scottyhardy/docker-remote-desktop/actions/workflows/build.yml)

Docker image with RDP server using [xrdp](http://xrdp.org) on Ubuntu 24.10 LTS with [XFCE](https://xfce.org) with Windows like look.
This project is based on the parent [docker-remote-desktop](https://github.com/scottyhardy/docker-remote-desktop) project.

## Build local docker image, run container and open RDP client:

All insturctions are prepared functions inside the [init.sh](init.sh) bash script.

To log in, use the following default user account details:

```bash
Username: demo
Password: changeit
```

## Screenshot of login prompt of `xfreerdp` application

![Screenshot of login prompt](screenshot_1.png)

## Screenshot of XFCE desktop

![Screenshot of XFCE desktop](screenshot_2.png)

