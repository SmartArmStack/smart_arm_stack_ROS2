#!/bin/bash
set -e
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)

# Pre-requisites
sudo apt-get update -q
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get install -y dh-make dh-python python3-bloom
# dch (devscripts): needed by sas_cpp's tools/bump-changelog.sh, which
# stamps the rolling version into debian/changelog before dpkg-buildpackage
sudo apt-get install -y devscripts

# sas_robot_driver_gazebo
sudo apt-get install libgz-transport13-dev

# cpp-interface-mujoco (libdqrobotics-interface-mujoco, for
# sas_robot_driver_mujoco): GLFW, OpenGL and EGL. MuJoCo itself is
# downloaded and built by its CMake (FetchContent) during dpkg-buildpackage.
sudo apt-get install -y libglfw3-dev libgl-dev libegl-dev ca-certificates
# sas_robot_driver_brov2: MAVROS messages and realtime_tools
sudo apt-get install -y ros-"${ROS_DISTRO}"-mavros-msgs ros-"${ROS_DISTRO}"-realtime-tools
