#! /usr/bin/env bash

# Create a label from git branch or commit hash of the parent directory or latest
GIT_LABEL="$(git branch --show-current | tr / -)"
if [[ -z "$GIT_LABEL" ]]; then
    GIT_LABEL="$(git -C .. rev-parse --short HEAD)"
    if [[ -z "$GIT_LABEL" ]]; then
        GIT_LABEL="latest"
    fi
fi
export GIT_LABEL=${GIT_LABEL}

# default ROS distro
export ROS_DISTRO="${ROS_DISTRO:-humble}"

# Image Tag and Container Name (override in enterpoint.sh)
export IMAGE_TAG="am/ros-${ROS_DISTRO}:${GIT_LABEL}"
export CONTAINER_NAME="${ROS_DISTRO}-container"

# Volume Settings
# ENTERPOINT_DIR="$(dirname $(realpath "$0"))"    # Get enterpoints's absolute directory path
export HOME_PATH="/root"
export WORKSPACE_PATH="/workspace"
