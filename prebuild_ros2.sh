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

# Python bindings for the OSQP solver (MarinhoLab/solver-osqp). The C++ side
# ships as the libmarinholab-solver-osqp .deb that build_ros2.sh builds; the
# Python package comes from PyPI. --break-system-packages is required on the
# ROS2 base images (PEP 668).
python3 -m pip install --upgrade marinholab-solvers-osqp --break-system-packages

# sas_robot_driver_gazebo
sudo apt-get install libgz-transport13-dev
