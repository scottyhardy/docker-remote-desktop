# Common functions for docker
# Usage: dstop; dstop; dbuild && drun && sleep 2 && dxrdp

DOCKER_IMAGE_NAME=remote-desktop
DOCKER_USER=demo
function dbuild { docker build -t ${DOCKER_IMAGE_NAME} . ; }
function drun {
  mkdir mkdir -p home/$DOCKER_USER
  docker run -d --shm-size 2g --rm \
         --name ${DOCKER_IMAGE_NAME}_01 \
         -p 3389:3389/tcp \
         -v $(pwd)/home/$DOCKER_USER:/home/$DOCKER_USER ${DOCKER_IMAGE_NAME};
}
function dbash  { docker exec -it ${DOCKER_IMAGE_NAME}_01 "$@" ;}
function dxrdp  { xfreerdp /v:localhost:3389 /u:$DOCKER_USER ;}
function dstop  { docker container stop ${DOCKER_IMAGE_NAME}_01 ;}
function dssh   { ssh $DOCKER_USER@localhost -p 2222 "$@" ;}
function dall   { dstop; dbuild && drun && sleep 2 && dxrdp ;}
function dpruneall { sudo docker system prune -a && sudo rm -rf home/ ;}
function dlogs  { mkdir -p logs/
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
