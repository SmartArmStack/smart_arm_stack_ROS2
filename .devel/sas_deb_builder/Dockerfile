# This image won't be uploaded to docker hub therefore not much concern with size
FROM juanjqo/ubuntu_24_dqrobotics_ros_jazzy
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# Update apt-get
RUN sudo apt-get update -q \
    && sudo apt-get upgrade -y \
    && sudo apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update dqrobotics to latest version
RUN python3 -m pip install --upgrade dqrobotics --break-system-packages

# SAS-RELATED THINGS (no need for recursive here)
RUN mkdir -p ~/sas_ws/src
RUN cd ~/sas_ws/src && git clone -b jazzy https://github.com/SmartArmStack/smart_arm_stack_ROS2.git sas

# BUILDER THINGS
RUN chmod +x ~/sas_ws/src/sas/.devel/prebuild_ros2.sh
RUN cd ~/sas_ws/src/sas/.devel && bash -c "./prebuild_ros2.sh"
RUN chmod +x ~/sas_ws/src/sas/.devel/build_ros2.sh
RUN cd ~/sas_ws/src/sas/.devel && bash -c "./build_ros2.sh"
