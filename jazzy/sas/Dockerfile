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

# Run install script
COPY --from=sas_repo jazzy/install.sh /root/sas_install/install.sh
RUN cd ~/sas_install \
    && chmod +x install.sh \
    && bash -c "./install.sh"
