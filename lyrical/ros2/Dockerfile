FROM ghcr.io/dqrobotics/container:resolute
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV="/etc/bash_env"

# Update apt-get
RUN apt-get update -q \
    && apt-get upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update dqrobotics to latest version
RUN python3 -m pip install --upgrade dqrobotics --break-system-packages

# Run install script
COPY --from=sas_repo lyrical/install_ros2.sh /root/sas_install/install_ros2.sh
WORKDIR /root/sas_install/
RUN chmod +x install_ros2.sh && . install_ros2.sh
