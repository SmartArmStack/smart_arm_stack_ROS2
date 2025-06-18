#!/bin/bash
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)
sudo rosdep init
rosdep update
sudo apt-get install python3-bloom
sudo apt-get install dh-make
sudo apt-get install qt5-qmake libqt5gui5 qtbase5-dev