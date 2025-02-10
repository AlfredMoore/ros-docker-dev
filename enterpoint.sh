#! /usr/bin/env bash

set -o errexit
set -o nounset

# Env
source ./env.sh

# user="${USER_ID}:${GROUP_ID}"

# BUILD IMAGE
if ! docker inspect "${IMAGE_TAG}" --type=image &> /dev/null; then
    echo "IMAGE ${IMAGE_TAG} not existing, BUILDING new image..."
    docker build \
        --tag "$IMAGE_TAG" \
        --file "ros-${ROS_DISTRO}.Dockerfile" \
        .
else
    echo "IMAGE ${IMAGE_TAG} already existing, if you want to build with newest dependecies, please manually build with no cache option"
fi

# GUI applications
xhost +local:docker > /dev/null


# RUN container args
args=(
    --rm    # autoremove the container
    --name "${CONTAINER_NAME}"

    # Interactivity
    --interactive
    --tty

    # host network
    --network=host

    # # hostname and localhost
    # --hostname="${CONTAINER_NAME}"
    # --add-host="${CONTAINER_NAME}":"127.0.0.1"        # Add localhost address manually

    # GUI applications
    --ipc=host
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:ro"
    --volume="/dev/dri:/dev/dri:ro"

    --privileged

    # Access all devices
    --device="/dev:/dev"
    --env="DISPLAY=$DISPLAY"
)

# default VOLUME_DIR
if [[ -n "${VOLUME_DIR:-}" ]]; then
    echo "Volume"
    args+=(
        # Workspace
        --volume="${VOLUME_DIR}:${WORKSPACE_PATH}"
        --workdir "${WORKSPACE_PATH}"
        --env "WORKSPACE_PATH=${WORKSPACE_PATH}"
    )
fi

# args+=(
#     # Realtime Kernel, if you are in RTkernel, uncomment the followings
#     --cap-add=SYS_NICE
#     --volume="${ENTERPOINT_DIR}/configs/limits.conf:/etc/security/limits.conf:ro"
# )

args+=(
    # Required
    "${IMAGE_TAG}"
    bash
)

# Create container if not
if [ -z "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo "CONTAINER ${CONTAINER_NAME} not existing, creating..."
    docker run "${args[@]}"
else
    echo "CONTAINER ${CONTAINER_NAME} existing and running, entering..."
    docker exec --interactive --tty "${CONTAINER_NAME}" bash
fi