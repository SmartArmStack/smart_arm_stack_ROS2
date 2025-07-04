FROM juanjqo/ubuntu_24_dqrobotics_ros_jazzy
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# Branch of this repository from which to download the install script
ARG BRANCH=jazzy

# Run install script
RUN mkdir -p ~/sas_install \
&& cd ~/sas_install \
&& curl -OL "https://raw.githubusercontent.com/SmartArmStack/smart_arm_stack_ROS2/refs/heads/${BRANCH}/install.sh" \
&& chmod +x install.sh \
&& bash -c "./install.sh"
