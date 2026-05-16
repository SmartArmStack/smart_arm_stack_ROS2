#!/bin/bash
set -e

# Add SAS apt sources
curl -s --compressed "https://smartarmstack.github.io/smart_arm_stack_ROS2/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/smartarmstack_lgpl.gpg >/dev/null
sudo curl -s --compressed -o /etc/apt/sources.list.d/smartarmstack_lgpl.list "https://smartarmstack.github.io/smart_arm_stack_ROS2/smartarmstack_lgpl.list"

# Update & upgrade apt
sudo apt-get update -q
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Install sas
sudo apt-get install ros-lyrical-sas-*

# Remove unused apt info
apt-get clean
rm -rf /var/lib/apt/lists/*
