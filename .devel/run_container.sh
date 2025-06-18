#!/bin/bash
set -e
# Based on juanjqo's https://github.com/Adorno-Lab/docker_recipes/blob/main/run_container.sh

docker run -it --name=sas_deb_builder \
--rm --privileged --network=host --env=DISPLAY \
sas_deb_builder /bin/bash