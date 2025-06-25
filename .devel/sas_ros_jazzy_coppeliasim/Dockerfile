# Firt version by @juanjqo
# https://github.com/Adorno-Lab/docker_recipes/blob/main/ubuntu_24/dqrobotics_coppeliasim/Dockerfile
FROM murilomarinho/sas_ros_jazzy

ARG COPPELIASIM_RELEASE=V4_7_0_rev4
ENV COPPELIASIM_RELEASE=$COPPELIASIM_RELEASE

ARG UBUNTU_VERSION=Ubuntu24_04
ENV UBUNTU_VERSION=$UBUNTU_VERSION

ARG COPPELIASIM_FILE="CoppeliaSim_Edu_${COPPELIASIM_RELEASE}_${UBUNTU_VERSION}.tar.xz"
ENV COPPELIASIM_FILE=$COPPELIASIM_FILE

SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

RUN cd ~/sas_install/sas && git pull
RUN chmod +x ~/sas_install/sas/.devel/scripts/setup_sas_ros_jazzy_coppeliasim.sh
RUN cd ~/sas_install/sas/.devel/scripts && bash -c "./setup_sas_ros_jazzy_coppeliasim.sh"