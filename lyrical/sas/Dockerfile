FROM ghcr.io/marinholab/ros:lyrical
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
COPY --from=sas_repo lyrical/install.sh /root/sas_install/install.sh
RUN cd ~/sas_install \
    && chmod +x install.sh \
    && bash -c "./install.sh"
