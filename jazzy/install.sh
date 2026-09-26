#!/bin/bash
set -e

# Add OSRF Gazebo (Harmonic) apt source.
# ros-jazzy-sas-robot-driver-gazebo (SAS >= 26.9.25095909) links sdformat14 /
# gz-math7, so its deb Depends on libsdformat14-dev and libgz-math7-dev, which
# are only in the OSRF Gazebo archive (not in Ubuntu/ROS2/dqrobotics repos).
curl -fsSL https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/gazebo-stable.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gazebo-stable.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list >/dev/null

# Add SAS apt sources
curl -s --compressed "https://smartarmstack.github.io/smart_arm_stack_ROS2/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/smartarmstack_lgpl.gpg >/dev/null
sudo curl -s --compressed -o /etc/apt/sources.list.d/smartarmstack_lgpl.list "https://smartarmstack.github.io/smart_arm_stack_ROS2/smartarmstack_lgpl.list"

# Update & upgrade apt
sudo apt-get update -q
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Install sas (the OSRF Gazebo source above covers the gazebo driver's
# libgz-math7-dev / libsdformat14-dev dependencies)
sudo apt-get install -y ros-jazzy-sas-*

# Remove unused apt info
apt-get clean
rm -rf /var/lib/apt/lists/*
