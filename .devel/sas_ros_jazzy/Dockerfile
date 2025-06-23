# From juanjo's dqrobotics_ros_jazzy
FROM juanjqo/ubuntu_24_dqrobotics_ros_jazzy
ARG ROS_DOMAIN_ID=1
ENV ROS_DOMAIN_ID=$ROS_DOMAIN_ID
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# ROS DOMAIN SETUP
RUN echo "export ROS_DOMAIN_ID=$ROS_DOMAIN_ID" >> ~/.bashrc

# Make directory and download sas installation instructions
RUN mkdir -p ~/sas_install
RUN cd ~/sas_install && git clone -b jazzy https://github.com/SmartArmStack/smart_arm_stack_ROS2.git sas

# Install SAS
RUN chmod +x ~/sas_install/sas/install.sh
RUN bash -c '~/sas_install/sas/install.sh'

