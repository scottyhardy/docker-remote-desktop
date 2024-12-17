# Common functions for docker
# Usage: dstop; dstop; dbuild && drun && sleep 2 && dxrdp

DOCKER_DIR=$(dirname "$0")
DOCKER_IMAGE_NAME=remote-desktop
DOCKER_USER=demo
function dbuild { cd "$DOCKER_DIR" && docker build -t ${DOCKER_IMAGE_NAME} . ; }
function drun {
  mkdir mkdir -p home/$DOCKER_USER
  docker run -d --rm --shm-size 2g \
         --name "${DOCKER_IMAGE_NAME}_01" \
         -p "3389:3389/tcp" \
         -v "$(pwd)/home/${DOCKER_USER}:/home/${DOCKER_USER}_" \
         ${DOCKER_IMAGE_NAME}
}
function dbash  { docker exec -it ${DOCKER_IMAGE_NAME}_01 "$@" ;}
function dxrdp  { xfreerdp /size:1920x1000 /bpp:32 /v:localhost:3389 /u:$DOCKER_USER ;}
function dstop  { docker container stop ${DOCKER_IMAGE_NAME}_01 ;}
function dssh   { ssh $DOCKER_USER@localhost -p 2222 "$@" ;}
function dall   { dstop; dbuild && drun && sleep 2 && dxrdp ;}
function dpruneall { sudo docker system prune -a && sudo rm -rf "$DOCKER_DIR/home/" ;}
function dlogs  {
  cd "$DOCKER_DIR" || exit 1
  mkdir -p "$DOCKER_DIR/logs/"

  echo "# cat /var/log/xrdp.log" > logs/xrdp.log
  dbash cat /var/log/xrdp.log   >> logs/xrdp.log

  echo "# cat /var/log/xrdp-sesman.log" > logs/xrdp-sesman.log
  dbash cat /var/log/xrdp-sesman.log   >> logs/xrdp-sesman.log

  echo "# cat .xorgxrdp.10.log" > logs/xorg.log
  dbash cat .xorgxrdp.10.log   >> logs/xorg.log

  echo DONE
}
