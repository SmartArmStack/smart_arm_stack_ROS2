#!/bin/bash
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)

# SAS-RELATED THINGS (no need for recursive here)
mkdir -p ~/sas_ws/src
cd ~/sas_ws/src || exit 1
git clone -b jazzy https://github.com/SmartArmStack/smart_arm_stack_ROS2.git sas

# Pre-requisites
sudo apt-get update
sudo apt-get install -y dh-make dh-python python3-bloom doxygen
sudo apt-get install --only-upgrade g++ cmake git python3-pybind11
