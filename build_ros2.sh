#!/bin/bash
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)
set -e

####################################################################
#                    Helper functions and parameters
####################################################################

# Change this to define the number of parallel jobs for this builder
export DEB_BUILD_OPTIONS=parallel=4

# ROS2 version
rosv=$1
# Ubuntu version
ubuntuv=$2

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

# Packages in https://github.com/SmartArmStack/
sas_pkg_array=(
"sas_core"
"sas_msgs"
"sas_conversions"
"sas_common"
"sas_datalogger"
"sas_robot_driver"
"sas_robot_kinematics"
#"sas_robot_driver_denso"
)

# Packages in https://github.com/MarinhoLab/
marinholab_pkg_array=(
"sas_force_sensor"
"sas_robot_driver_coppeliasim"
"sas_robot_driver_kuka"
"sas_robot_driver_ur"
"sas_force_sensor_bota"
"sas_robot_driver_gazebo"
)

####################################################################
# Update rosdep only once
####################################################################

if [ ! -f "$HOME/rosdep_sas_lgpl.yaml" ]; then
    # Create link
    ln -s "$PWD/rosdep_sas_lgpl.yaml" "$HOME/rosdep_sas_lgpl.yaml"

    # Rosdep
    rosdep init

    # Add sas packages to rosdep
    cd ~ || exit 1
    echo "yaml file:///$HOME/rosdep_sas_lgpl.yaml" | tee -a /etc/ros/rosdep/sources.list.d/20-default.list

    # Update rosdep
    rosdep update
fi


####################################################################
#                     Create and cd tmp folder
####################################################################

rm -rf tmp_ros2
mkdir tmp_ros2
cd tmp_ros2

####################################################################
#                        Clone all packages
####################################################################

echo "Cloning packages at SmartArmStack"
for pkg_name in "${sas_pkg_array[@]}"; do
  echo "Cloning ${pkg_name}"
  git clone -b "$rosv" https://github.com/SmartArmStack/"$pkg_name".git --recurse-submodules
done

echo "Cloning packages at MarinhoLab"
for pkg_name in "${marinholab_pkg_array[@]}"; do
  echo "Cloning ${pkg_name}"
  git clone -b "$rosv" https://github.com/MarinhoLab/"$pkg_name".git --recurse-submodules
done

####################################################################
#                        Define version number
####################################################################

# Remove any leading zeros otherwise the version name will not fit the bloom requirements
# https://unix.stackexchange.com/questions/79371/removing-leading-zeros-from-date-output
VERSION=$(date +"%-y.%-m.%-d%H%M%S")
echo "version=${VERSION}" > SAS_VERSION

####################################################################
#   Non-ROS C++ .debs (MarinhoLab, built from their own debian/ packaging)
#
# These are ROS-independent C++ libraries with no package.xml, so they
# cannot go through the bloom loop below. Each is built and installed
# before colcon build, from its own debian/ packaging
# (dpkg-buildflags-based CMake rules) via dpkg-buildpackage.
#
# Add new ones to cpp_deb_array as they arrive. Every package must share
# the layout used here:
#   - a debian/ directory buildable with dpkg-buildpackage
#   - tools/bump-changelog.sh (needs dch from devscripts, see
#     prebuild_ros2.sh) that stamps the rolling YY.MM.NN version
#   - tools/version.sh (full clone, no --depth, so it can count commits
#     since the monthly tag)
#
# The ref is overridable per package via an env var named <REPO>_REF
# (e.g. SAS_CPP_REF, SOLVER_QPOASES_REF); defaults to the repo's default
# branch. The .deb is installed by the Source: name in its debian/control,
# and lands in tmp_ros2/ so the PPA extract step (cp -f
# /root/tmp_ros2/*.deb) ships it with the ROS package .debs.
####################################################################

# Repos in https://github.com/MarinhoLab/ that produce a libmarinholab-* .deb
cpp_deb_array=(
"sas_cpp"
"solver-qpoases"
"solver-osqp"
)

for cpp_repo in "${cpp_deb_array[@]}"; do
  # Ref override env var, e.g. sas_cpp -> SAS_CPP_REF
  cpp_ref_var="$(echo "$cpp_repo" | tr '[:lower:]-' '[:upper:]__')_REF"
  cpp_ref="${!cpp_ref_var:-main}"
  echo "Building from ${cpp_repo} @ ${cpp_ref}"
  git clone --branch "$cpp_ref" \
      "https://github.com/MarinhoLab/${cpp_repo}.git" --recurse-submodules
  cd "$cpp_repo"
  bash tools/bump-changelog.sh
  dpkg-buildpackage -us -uc -b
  # Install by the Source: name declared in debian/control (robust to the
  # .deb name not matching the repo name, e.g. sas_cpp -> libmarinholab-sas-core).
  # dpkg-buildpackage writes the .deb into the parent of the source dir, so
  # we are already back in tmp_ros2/ here. The trailing glob must stay
  # unquoted or the * is passed through literally and nothing matches.
  cpp_src="$(sed -nE 's/^Source:[[:space:]]*(.*)$/\1/p' debian/control | head -n1)"
  cd ..
  dpkg -i ./"${cpp_src}"_*.deb
done

####################################################################
#                  Check with colcon first
####################################################################

source /opt/ros/"$rosv"/setup.bash
colcon build

####################################################################
#                   Build and install incrementally
####################################################################

combined_pkg_array=(  "${sas_pkg_array[@]}" "${marinholab_pkg_array[@]}"  )
for pkg_name in "${combined_pkg_array[@]}"; do
  echo "Building ${pkg_name}"
  cd "$pkg_name"
  PRE_BUILD
  BUILD_DEB
  cd ..
  # Install package but replace _ by -. E.g. sas_core becomes sas-core.
  # https://stackoverflow.com/questions/3306007/replace-a-string-in-shell-script-using-a-variable
  dpkg -i ros-"$rosv"-"${pkg_name//_/-}"_*"$ubuntuv"*.deb
  ${var//12345678/$replace}
done
