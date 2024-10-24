#! /usr/bin/env bash

set -o errexit
set -o nounset

source ./env.sh

# build image if not
if ! docker inspect "${IMAGE_TAG}" --type=image &> /dev/null; then
    echo -e "\e[33m${IMAGE_TAG} not existing, start building IMAGE ${IMAGE_TAG}...\e[0m"
    docker buildx bake -f panda-bake.hcl
    echo -e "\e[33mImage Built Sucessfully\e[0m"
else
    echo -e "\e[33m${IMAGE_TAG} already existing...\e[0m"
fi

# GUI applications
xhost +local:docker > /dev/null

# Arguments to run container
args=(
    # --rm    # autoremove the container
    --name "${CONTAINER_NAME}"

    # Interactivity
    --interactive
    --tty

    # host network
    --network=host

    # hostname and localhost
    --hostname="${CONTAINER_NAME}"
    --add-host="${CONTAINER_NAME}":"127.0.0.1"        # Add localhost address manually

    # GUI applications
    --ipc=host
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:ro"
    --volume="/dev/dri:/dev/dri:ro"

    # User spoofing
    --group-add="sudo"
    --user="${USER_ID}:${GROUP_ID}"      # Align with Dockerfile
    --volume="/etc/group:/etc/group:ro"
    --volume="/etc/passwd:/etc/passwd:ro"
    --volume="/etc/shadow:/etc/shadow:ro"

    # GPU device

    # PID exposure 

    # Realtime Kernel, if you are in RTkernel, uncomment the followings
    # --privileged
    # --cap-add=SYS_NICE

    # Workspace
    --workdir "/home/${USERNAME}/"

    # start image
    "${IMAGE_TAG}"
    "${SHELL}"
)

# Create container if not
if [ -z "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "\e[32mContainer ${CONTAINER_NAME} not existing. Create and run the container\e[0m"
    docker run "${args[@]}"
else
    # Start the stopped container
    if [ -z "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo -e "\e[32mContainer ${CONTAINER_NAME} existing but stopped. Start and run the container\e[0m"
        docker start ${CONTAINER_NAME}
        docker exec --interactive --tty \
                    --user="${USER_ID}:${GROUP_ID}" \
                    --workdir "/home/${USERNAME}/" \
                    "${CONTAINER_NAME}" "${SHELL}"
    # Enter to a runnning container
    else
        echo -e "\e[32mContainer ${CONTAINER_NAME} existing and running. Enter the container with a new section\e[0m"
        docker exec --interactive --tty \
                    --user="${USER_ID}:${GROUP_ID}" \
                    --workdir "/home/${USERNAME}/" \
                    "${CONTAINER_NAME}" "${SHELL}"
    fi
fi