# Common functions for the docker project: ubuntu-docker-desktop-xrdp
# Usage: . init.sh; dbuild; drun; dxrdp

DOCKER_DIR=$(dirname "$0")
DOCKER_IMAGE_NAME=remote-desktop
DOCKER_USER=demo

# Build docker image
function dbuild { cd "$DOCKER_DIR" && docker build -t ${DOCKER_IMAGE_NAME} . ; }
# Run docker container
function drun {
  mkdir mkdir -p home/$DOCKER_USER
  docker run -d --rm --shm-size 2g \
         --name "${DOCKER_IMAGE_NAME}_01" \
         -p "3389:3389/tcp" \
         -v "$(pwd)/home/${DOCKER_USER}:/home/${DOCKER_USER}" \
         ${DOCKER_IMAGE_NAME}
}
# Run a command or bash.
function dbash  { docker exec -it ${DOCKER_IMAGE_NAME}_01 "$@" ;}
# Run Xrdp client.
function dxrdp  { xfreerdp /size:1200x800 /bpp:32 /v:localhost:3389 /u:$DOCKER_USER ;}
# Stop the docker container
function dstop  { docker container stop ${DOCKER_IMAGE_NAME}_01 ;}
# Run the ssh client.
function dssh   { ssh $DOCKER_USER@localhost -p 2222 "$@" ;}
# Run functions: dstop; dbuild; drun; dxrdp
function dall   { dstop; dbuild && drun && sleep 2 && dxrdp ;}
# Removes all unused Docker objects including persistent home directory of the docker user `demo`.
function dpruneall { sudo docker system prune -a && sudo rm -rf "$DOCKER_DIR/home/" ;}

