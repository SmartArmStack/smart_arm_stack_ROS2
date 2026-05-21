#!/bin/bash
set -e
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)

# Pre-requisites
sudo apt-get update -q
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get install -y dh-make dh-python python3-bloom

# sas_robot_driver_gazebo
sudo apt-get install libgz-transport13-dev
