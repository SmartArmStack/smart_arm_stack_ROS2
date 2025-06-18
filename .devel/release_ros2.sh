#!/bin/bash
set -e
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)

####################################################################
#                   Release on github
####################################################################

# Get arch to differentiate releases
arch=$(uname -i)
# Release on Github
gh release create v"$VERSION" ros-"$rosv"-sas-*.deb -t v"$VERSION"_"$arch" --notes "Latest automated release for $arch" --repo git@github.com:SmartArmStack/smart_arm_stack_ROS2.git
