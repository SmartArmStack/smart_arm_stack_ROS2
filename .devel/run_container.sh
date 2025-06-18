#!/bin/bash

# Based on juanjqo's https://github.com/Adorno-Lab/docker_recipes/blob/main/run_container.sh

echo "Running container:" $1
# Argument validation check
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    echo "Example: sh run_container.sh ubuntu_24_dqrobotics"
    exit 1
fi

#/opt/X11/bin/xhost +local:root
#xhost +local:root
docker run -it --name=$1 \
--rm --privileged --network=host --env=DISPLAY --platform=linux/amd64 \
$1 /bin/bash