#!/bin/bash
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)
set -e

####################################################################
#                    Helper functions and parameters
####################################################################

# Change this to define the number of parallel jobs for this builder
export DEB_BUILD_OPTIONS=parallel=4

# ROS2 version
rosv="jazzy"
# Ubuntu version
ubuntuv="noble"
# Architecture
archname="amd64"

PRE_BUILD() {
# Remove the debian folder just in case. In ROS1 and catkin this was an issue
rm -rf debian
# Use the --all just in case, otherwise it returns with an error if there are multiple commits without a changelog
# wow, with the --all it also complains if the package already has a changelog. Nice, thanks a lot
catkin_generate_changelog --all || true
catkin_generate_changelog || true
# If we don't commit the modified CHANGELOG.rst, the catkin_prepare_release doesn't shut up about it
git add CHANGELOG.rst
git config user.email "builder@dontannoy.me"
git config user.name "Builder"
git commit -a -m "Shut up catkin"
# Apparently this doesn't work for python-only packages, but we not care cause we cmake boyz
catkin_prepare_release --no-push -y --version "$VERSION"
# Automagically create the debian packagking directives
bloom-generate rosdebian --os-name ubuntu --os-version "$ubuntuv" --ros-distro "$rosv"
}

BUILD_DEB(){
# Parallel builds
sed -i -e 's/dh $@/dh $@ --parallel/g' debian/rules
# A hack so that shlibdeps does not complain about qpOases not being a ubuntu package. Well, it is being installed purely using CMAKE.
# This might create other problems, but for now we worry about being able build the package at all.
sed -i -e 's/dh_shlibdeps /dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info /g' debian/rules
fakeroot debian/rules binary
}

####################################################################
#                        Array of packages
####################################################################
pkg_array=(
"sas_core"
"sas_msgs"
"sas_common"
"sas_conversions"
"sas_datalogger"
"sas_robot_driver"
"sas_robot_kinematics"
)

####################################################################
#                        Create tmp folder
####################################################################

rm -rf tmp_ros2
mkdir tmp_ros2
cd tmp_ros2

####################################################################
#                        Clone all packages
####################################################################

#Example https://github.com/SmartArmStack/smart_arm_stack_ROS2.git
for pkg_name in "${pkg_array[@]}"; do
  echo "Cloning ${pkg_name}"
  git clone -b "$rosv" https://github.com/SmartArmStack/"$pkg_name".git --recurse-submodules
done

####################################################################
#                        Define version number
####################################################################

# Remove any leading zeros otherwise the version name will not fit the bloom requirements
# https://unix.stackexchange.com/questions/79371/removing-leading-zeros-from-date-output
VERSION=$(date +"%-y.%-m.%-d%H%M%S")

####################################################################
#                   Remove current installation
####################################################################

# Remove all related packages. The || true is so that it doesn't annoy us when something wasn't installed to begin with.
sudo apt remove ros-"$rosv"-sas* -y || true

####################################################################
#                   Build and install incrementally
####################################################################

for pkg_name in "${pkg_array[@]}"; do
  echo "Building ${pkg_name}"
  cd "$pkg_name"
  PRE_BUILD
  BUILD_DEB
  cd ..
  # Install package but replace _ by -. E.g. sas_core becomes sas-core.
  # https://stackoverflow.com/questions/3306007/replace-a-string-in-shell-script-using-a-variable
  sudo dpkg -i ros-"$rosv"-"${pkg_name//_/-}"_*"$ubuntuv"_"$archname".deb
  ${var//12345678/$replace}
done
