#! /usr/bin/env bash

sudo rosdep update
sudo rosdep install --from-paths src --ignore-src --rosdistro noetic  -y --skip-keys libfranka

sudo pip3 install panda_robot numpy==1.21
sudo apt update && sudo apt install -y \
    libpoco-dev libeigen3-dev\
    python3-rosdep\
    mesa-utils\
    ros-noetic-gazebo-ros-control\
    ros-noetic-rospy-message-converter\
    ros-noetic-effort-controllers\
    ros-noetic-joint-state-controller\
    ros-noetic-moveit\
    ros-noetic-moveit-commander\
    ros-noetic-moveit-visual-tools