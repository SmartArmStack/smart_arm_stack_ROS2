# From juanjo's dqrobotics_ros_jazzy
FROM juanjqo/ubuntu_24_dqrobotics
ARG ROS_DOMAIN_ID=1
ENV ROS_DOMAIN_ID=$ROS_DOMAIN_ID
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# INSTALL ROS2 JAZZY
## This script is part of the repository cloned in juanjqo/ubuntu_24_dqrobotics
RUN chmod +x ~/git/docker_recipes/dependencies/install_ros_jazzy.sh
RUN bash -c '~/git/docker_recipes/dependencies/install_ros_jazzy.sh'

# ROS DOMAIN SETUP
RUN echo "export ROS_DOMAIN_ID=$ROS_DOMAIN_ID" >> ~/.bashrc

# SAS-RELATED THINGS
RUN mkdir -p ~/sas_ws/src
RUN cd ~/sas_ws/src
RUN git clone --recurse-submodules -b jazzy https://github.com/SmartArmStack/smart_arm_stack_ROS2.git sas