#!/bin/bash
set -e
# Copyright (c) Murilo M. Marinho (www.murilomarinho.info)

# Pre-requisites
sudo apt-get update -q
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get install -y dh-make dh-python python3-bloom
