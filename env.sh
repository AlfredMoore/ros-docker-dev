#! /usr/bin/env bash

# Create a label from git config
GIT_LABEL="$(git branch --show-current | tr / -)"
if [[ -z "$GIT_LABEL" ]]; then
    GIT_LABEL="$(git rev-parse --short HEAD)"
fi

# Get enterpoints's absolute directory path
ENTERPOINT_DIR="$(dirname $(realpath "$0"))"

# Image Tag and  Container Name
export IMAGE_TAG="WiscHCI/panda-noetic:${GIT_LABEL}"
export CONTAINER_NAME="ros-panda-noetic"

# User configs
export USERNAME=$(whoami)
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
# export DISPLAY=${DISPLAY}