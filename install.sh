# Make a temporary directory
mkdir -p smart_arm_stack_ros2_installation
cd smart_arm_stack_ros2_installation
# Remove existing packages, if any, and don't complain if there are none
sudo apt remove ros-humble-sas* -y || true
# Download files
wget $(curl -sL https://api.github.com/repos/smartarmstack/smart_arm_stack_ROS2/releases/latest | jq -r '.assets[].browser_download_url')
# Install packages
sudo dpkg -i  ros-humble-sas-*.deb
# Remove temporary folder and itself
cd ..
rm -r smart_arm_stack_ros2_installation
rm -- "$0"
