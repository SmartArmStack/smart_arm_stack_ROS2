# This image won't be uploaded to docker hub therefore not much concern with size
FROM ghcr.io/marinholab/gazebo:jazzy
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

# Required (as deb Depends) by ros-jazzy-sas-datalogger / -force-sensor /
# -robot-driver-gazebo, which the loop below installs with plain dpkg -i.
# The GUI runtime itself comes from pip (see jazzy/sas/Dockerfile); these
# apt packages exist to satisfy the generated deb dependency metadata.
RUN sudo apt-get update -q \
    && sudo apt-get install -y python3-pyqt6 python3-pyqtgraph \
    && apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Build scripts
COPY --from=sas_repo prebuild_ros2.sh build_ros2.sh jazzy/rosdep_sas_lgpl.yaml /root/sas_ws/src/sas/

WORKDIR /root/sas_ws/src/sas
RUN chmod +x prebuild_ros2.sh && . prebuild_ros2.sh
RUN chmod +x build_ros2.sh && . build_ros2.sh jazzy noble
