# From juanjo's dqrobotics_ros_jazzy
FROM juanjqo/ubuntu_24_dqrobotics_ros_jazzy
ARG ROS_DOMAIN_ID=1
ENV ROS_DOMAIN_ID=$ROS_DOMAIN_ID
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# ROS DOMAIN SETUP
RUN echo "export ROS_DOMAIN_ID=$ROS_DOMAIN_ID" >> ~/.bashrc

# SAS-RELATED THINGS (no need for recursive here)
RUN mkdir -p ~/sas_ws/src
RUN cd ~/sas_ws/src && git clone -b jazzy https://github.com/SmartArmStack/smart_arm_stack_ROS2.git sas

# BUILDER THINGS
RUN chmod +x ~/sas_ws/src/sas/.devel/prebuild_ros2.sh
RUN cd ~/sas_ws/src/sas/.devel && bash -c "./prebuild_ros2.sh"
RUN chmod +x ~/sas_ws/src/sas/.devel/build_ros2.sh
RUN cd ~/sas_ws/src/sas/.devel && bash -c "./build_ros2.sh"
