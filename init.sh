# Common functions for docker
# Usage: dstop; dbuild && drun && sleep 1 && dxrdp

DOCKER_IMAGE_NAME=remote-desktop
function dbuild { docker build -t ${DOCKER_IMAGE_NAME} . ; }
function drun   { docker run -d --shm-size 2g --rm --name ${DOCKER_IMAGE_NAME}_01 -p 3389:3389/tcp ${DOCKER_IMAGE_NAME} ; }
function dbash  { docker exec -it ${DOCKER_IMAGE_NAME}_01 "$@" ; }
function dxrdp  { xfreerdp /v:localhost:3389 /u:ubuntu ; }
function dstop  { docker container stop ${DOCKER_IMAGE_NAME}_01 ; }
function dssh   { ssh demo@localhost -p 2222 "$@" ;}
function dlogs  { mkdir -p logs/
function dall   { dstop; dbuild; drun; }

  echo "# xrdp --version" > logs/xrdp-version.log
  dbash xrdp --version   >> logs/xrdp-version.log

  echo "# cat /var/log/xrdp.log" > logs/xrdp.log
  dbash cat /var/log/xrdp.log   >> logs/xrdp.log

  echo "# cat /var/log/xrdp-sesman.log" > logs/xrdp-sesman.log
  dbash cat /var/log/xrdp-sesman.log   >> logs/xrdp-sesman.log

  echo "# cat .xorgxrdp.10.log" > logs/xorg.log
  dbash cat .xorgxrdp.10.log   >> logs/xorg.log

  echo DONE
}
