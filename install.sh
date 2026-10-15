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
#
# The solver libraries are named explicitly because nothing in the ROS package
# set depends on them (they are linked PRIVATE and their symbols are hidden),
# so installing the ros-jazzy-sas-* set alone leaves them out -- and
# find_package(marinholab_solver_*) then fails for anything building against
# them. See MarinhoLab/solver-qpoases and MarinhoLab/solver-osqp.
sudo apt-get install -y \
    libmarinholab-solver-qpoases \
    libmarinholab-solver-osqp

# The ros-jazzy-sas-* packages are expanded by hand instead of being handed to
# apt as a glob. Unquoted, the shell leaves the pattern literal when nothing in
# the current directory matches it, and apt then reads it as a regex that also
# selects the -dbgsym packages, whose unresolvable dependencies can abort the
# whole transaction. Expanding it here keeps the debug symbols out.
mapfile -t sas_packages < <(apt-cache pkgnames "ros-jazzy-sas-" 2>/dev/null \
    | grep -E "^ros-jazzy-sas-" | grep -Ev -- '-dbgsym$' | sort -u)
if ((${#sas_packages[@]} == 0)); then
    echo "install.sh: no ros-jazzy-sas-* packages found. Is the apt source reachable?" >&2
    exit 1
fi
sudo apt-get install -y "${sas_packages[@]}"

# Remove unused apt info
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
