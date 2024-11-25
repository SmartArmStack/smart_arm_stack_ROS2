# Package Summary

*Research only* packages cannot be used for commercial use.

| Package                                    | License       | Description                                                                                                                   |
|--------------------------------------------|---------------|-------------------------------------------------------------------------------------------------------------------------------|
| `sas_core`                                 | LGPL          | The part of the library that does not depend on `ROS2`.                                                                       |
| `sas_common`                               | LGPL          | Generic `ROS2` code used throughout the packages.                                                                             |
| `sas_msgs`                                 | LGPL          | A wrapper for `ROS` messages that were made redundant in `ROS2`.                                                              |
| `sas_conversions`                          | LGPL          | Convert `ROS2` messages into `float`, `int`, or `dqrobotics` elements.                                                        |
| `sas_robot_driver`                         | LGPL          | `ROS2` nodes and libraries for creating servers and clients for robot configuration-space monitoring and control.             |
| `sas_robot_kinematics`                     | LGPL          | `ROS2` nodes and libraries for creating servers and clients for kinematic-level robot task-space monitoring and control.      |
| `sas_robot_driver_denso`                   | LGPL          | A `sas_robot_driver` implementation for DensoWave's bCap controlled robots                                                    |
| `sas_robot_driver_kuka`                   | LGPL          | A `sas_robot_driver` implementation for Kuka (Sunrise cabinet, FRI)                                                    |
| `sas_robot_driver_ur`                   | LGPL          | A `sas_robot_driver` implementation for UR                                                     |


# Prerequisites
1. [ROS 2 Jazzy](https://docs.ros.org/en/jazzy/Installation/Alternatives/Ubuntu-Development-Setup.html)
2. DQ Robotics CPP ([Development branch](https://dqroboticsgithubio.readthedocs.io/en/latest/installation/cpp.html#development-ppa))
```commandline
sudo add-apt-repository ppa:dqrobotics-dev/development
sudo apt-get update
sudo apt-get install libdqrobotics libdqrobotics-interface-json11 libdqrobotics-interface-coppeliasim libdqrobotics-interface-coppeliasim-zmq
```
3. DQ Robotics Python ([pre-release](https://dqroboticsgithubio.readthedocs.io/en/latest/installation/python.html#installation-development))
```commandline
python3 -m pip install dqrobotics --pre
```

_**It is important to update the Python version to `4.7.0-2` if the interface is going to be used in Python.**_

# Do once

On the ROS2 workspace, e.g. `~/ros2_ws/src`

```commandline
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
git clone git@github.com:SmartArmStack/smart_arm_stack_ROS2.git sas --recursive
```

then

```commandline
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
```

# Every build

```commandline
cd ~/ros2_ws/src
colcon build 
source install/setup.bash
```

# Opening a package on QTCreator

1. First, be sure that the environment has been compiled and sourced as shown in the last step.

2. In that same terminal, open QTCreator, e.g. by running
```commandline
qtcreator
```

3. Open a new project and find the `CMakeLists.txt` of each package, e.g. `sas_core/CMakeLists.txt`.
- `File` > `Open File or Project...` > Choose `sas/sas_core/CMakeLists.txt`

The default suggested configuration will work, but might generate issues with `colcon` because of where the build folder is made. It is better to import the build from `build/PACKAGE_NAME` so that QTCreator uses the same build space.
- Deselect `Desktop` by unchecking the checkbox.
- `Import build from...` > `Details` > `Browse...` > `~/ros2ws/src/build/sas_core` > `Open` > `Import` 

At this stage, the import is succesfull if the option `Build` shows up already checked.

- Lastly, click `Configure Project`.

4. If the initial configuration is messed up, just delete the `CMakeLists.txt.user` inside each wrongly configured package. Note the trailing `.user`.


