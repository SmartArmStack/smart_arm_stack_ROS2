#!/bin/bash
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)
set -e

# ROS2 version
rosv=$1

mkdir -p upload

docker run -t -d --name extract_files "$rosv"/sas_deb_builder || true
docker exec extract_files bash -c "mkdir -p ~/extract; cp -f /root/tmp_ros2/*.deb ~/extract; cp -f /root/tmp_ros2/SAS_VERSION ~/extract"
# Debug symbol packages
docker exec extract_files bash -c "mkdir -p ~/extract; cp -f /root/tmp_ros2/*.ddeb ~/extract; cp -f /root/tmp_ros2/SAS_VERSION ~/extract"
docker cp extract_files:/root/extract upload/
