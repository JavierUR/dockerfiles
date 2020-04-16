# Script to create ros development environment with hardware access
# Run with name argument ./createHost.sh <name>
docker run -it \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --group-add "video" \
    --group-add "sudo" \
    --gpus all \
    -e NVIDIA_DRIVER_CAPABILITIES=graphics,compute \
    --device="/dev/video0" \
    -e DISPLAY=unix$DISPLAY \
    --env="QT_X11_NO_MITSHM=1" \
    --workdir="/home/$USER" \
    --volume="/home/$USER/rosDevelopment:/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name $1 \
    --network host \
    --privileged \
    rostorch \
    terminator -u
