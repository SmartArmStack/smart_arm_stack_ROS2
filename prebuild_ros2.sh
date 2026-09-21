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
