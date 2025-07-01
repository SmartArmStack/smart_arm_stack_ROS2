#!/bin/bash
set -e
# Based on https://github.com/Adorno-Lab/docker_recipes/blob/8a94fb42c7fc7579343f83584c00108536366faf/dependencies/install_coppeliasim.sh#L1

apt-get update -q
apt-get install -y --no-install-recommends \
    curl tar xz-utils \
    libx11-6 libxcb1 libxau6 libgl1-mesa-dev \
    xvfb dbus-x11 x11-utils libxkbcommon-x11-0 \
    libavcodec-dev libavformat-dev libswscale-dev \
    python3 python3-pip python3-venv libraw1394-11 libmpfr6 \
    libusb-1.0-0
# Clean up unused packages
apt-get clean
rm -rf /var/lib/apt/lists/*

python3 -m pip install pyzmq cbor2 --break-system-packages

mkdir -p ~/utils
cd ~/utils || exit 1

echo "Downloading ${COPPELIASIM_FILE}."
curl --progress-bar --remote-name --location \
https://downloads.coppeliarobotics.com/"${COPPELIASIM_RELEASE}"/"${COPPELIASIM_FILE}" || exit 1

echo "Extracting ${COPPELIASIM_FILE}."
tar -xf "${COPPELIASIM_FILE}"
# Remove downloaded file to save space
rm "${COPPELIASIM_FILE}"

echo "Setting environment variables for ${COPPELIASIM_FILE}."
COPPELIASIM_PATH="${HOME}/utils/CoppeliaSim_Edu_${COPPELIASIM_RELEASE}_${UBUNTU_VERSION}"

# Add path for interactive scripts
echo "export COPPELIASIM_PATH=${COPPELIASIM_PATH}" \
>> ~/.bashrc
# Add path for noninteractive scripts
echo "export COPPELIASIM_PATH=${COPPELIASIM_PATH}" \
>> /etc/bash_env

# Aliases do not expand in non-interactive shells
echo "alias coppeliasim=${COPPELIASIM_PATH}/coppeliaSim.sh &" \
>> ~/.bashrc
