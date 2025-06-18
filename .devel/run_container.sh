#!/bin/bash

# Based on juanjqo's https://github.com/Adorno-Lab/docker_recipes/blob/main/run_container.sh

docker run -it --name=sas_deb_builder \
--rm --privileged --network=host --env=DISPLAY --platform=linux/amd64 \
sas_deb_builder /bin/bash