# This image won't be uploaded to docker hub therefore not much concern with size
FROM lyrical/ros2:latest
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

# Build scripts
COPY --from=sas_repo prebuild_ros2.sh build_ros2.sh lyrical/rosdep_sas_lgpl.yaml /root/sas_ws/src/sas/

WORKDIR /root/sas_ws/src/sas
RUN chmod +x prebuild_ros2.sh && . prebuild_ros2.sh
RUN chmod +x build_ros2.sh && . build_ros2.sh lyrical resolute
