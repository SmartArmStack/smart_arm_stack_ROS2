# Prerequisites

1. [ROS 2 Humble](https://docs.ros.org/en/humble/Installation/Alternatives/Ubuntu-Development-Setup.html)
2. DQ Robotics CPP ([Development branch](https://dqroboticsgithubio.readthedocs.io/en/latest/installation/cpp.html#development-ppa))
```commandline
sudo add-apt-repository ppa:dqrobotics-dev/development
sudo apt-get update
sudo apt-get install libdqrobotics*
```
3. DQ Robotics Python ([pre-release](https://dqroboticsgithubio.readthedocs.io/en/latest/installation/python.html#installation-development))
```commandline
python3 -m pip install dqrobotics --pre
```

# Devel

```commandline
colcon build --symlink-install
source install/setup.bash
```