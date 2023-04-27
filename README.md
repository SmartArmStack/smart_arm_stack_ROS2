# Packages TD;DR

| Package                | Description                                                                                                              |
|------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `sas_core`             | The part of the library that does not depend on `ROS2`.                                                                  |
| `sas_common`           | Generic `ROS2` code used throughout the packages.                                                                        |
| `sas_msgs`             | A wrapper for `ROS` messages that were made redundant in `ROS2`.                                                         |
| `sas_conversions`      | Convert `ROS2` messages into `float`, `int`, or `dqrobotics` elements.                                                   |
| `sas_robot_driver`     | `ROS2` nodes and libraries for creating servers and clients for robot configuration-space monitoring and control.        |
| `sas_robot_kinematics` | `ROS2` nodes and libraries for creating servers and clients for kinematic-level robot task-space monitoring and control. |

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

## Do once

On the ROS2 workspace, e.g. `~/ros2_ws/src`

```commandline
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
git clone git@github.com:SmartArmStack/smart_arm_stack_ROS2.git sas --recursive
```

## Every build

```commandline
cd ~/ros2_ws/src
colcon build --symlink-install
source install/setup.bash
```

## Aliases

Optionally, also install
```commandline
sudo apt install python3-colcon-clean
```

Then add the following aliases to `.bashrc`

```commandline
alias cdros2="cd ~/ros2_ws/src"
alias cleanros2="cdros2 && colcon clean workspace"
alias buildros2="cdros2 && colcon build --symlink-install && source install/setup.bash"
```

So that the following become `bash` commands become available 

- `cdros2`: go to the source of your ros2 workspace.
- `cleanros2`: clean the workspace, e.g. remove the `install`, `build`, and `log` folders.
- `buildros2`: do a standard build of the workspace and source the `setup.bash`.

## Opening a package on QTCreator

1. First, open a terminal and run
```commandline
buildros2
```

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


