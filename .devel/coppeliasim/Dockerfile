# Firt version by @juanjqo
FROM ubuntu:noble
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# Some smart environment variables by @juanjqo
ARG COPPELIASIM_RELEASE=V4_7_0_rev4
ARG UBUNTU_VERSION=Ubuntu24_04

ENV COPPELIASIM_RELEASE=$COPPELIASIM_RELEASE
ENV UBUNTU_VERSION=$UBUNTU_VERSION
ARG COPPELIASIM_FILE="CoppeliaSim_Edu_${COPPELIASIM_RELEASE}_${UBUNTU_VERSION}.tar.xz"
ENV COPPELIASIM_FILE=$COPPELIASIM_FILE

# Install git
RUN apt-get update -q && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and run sas coppeliasim install script 
RUN mkdir -p ~/sas_install/coppelia_install/ \
&& cd ~/sas_install/coppelia_install/ \
&& curl -OL https://raw.githubusercontent.com/SmartArmStack/smart_arm_stack_ROS2/refs/heads/jazzy/.devel/scripts/setup_coppeliasim.sh \
&& chmod +x setup_coppeliasim.sh \
&& bash -c "./setup_coppeliasim.sh"
