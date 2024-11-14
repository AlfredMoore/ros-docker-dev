#! /usr/bin/env bash

set -o errexit
set -o nounset

source ./env.sh

# Parse flags
use_cache='false'
use_bash='false'
use_realtime='false'

while getopts 'cber' flag; do
  case "${flag}" in
    c) use_cache='true' ;;
    b) use_bash='true' ;;
    r) use_realtime='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

if [ "${use_cache}" = 'true' ]; then
    echo -e "Use \e[33mcache\e[0m to build the image"
    export NOCACHE=false
else
    echo -e "Use \e[33mno cache\e[0m to build the image"
    export NOCACHE=true
fi

if [ "${use_bash}" = 'true' ]; then
    echo -e "Use \e[33mbash\e[0m as the shell"
    sh="/bin/bash"
else
    echo -e "Use \e[33mzsh\e[0m as the shell"
    sh="/bin/zsh"
fi

if [ "${use_realtime}" = 'true' ]; then
    echo -e "Enable \e[33mRealtime Kernel\e[0m"
else
    echo -e "Only Use \e[33mNormal Kernel\e[0m"
fi
#############################################################


# build image if not
if ! docker inspect "${IMAGE_TAG}" --type=image &> /dev/null; then
    echo -e "\e[33mIMAGE ${IMAGE_TAG} not existing, start building IMAGE ${IMAGE_TAG}...\e[0m"
    docker buildx bake -f panda-bake.hcl
    echo -e "\e[33mImage Built Sucessfully\e[0m"
else
    echo -e "\e[33mIMAGE ${IMAGE_TAG} already existing...\e[0m"
fi

# GUI applications
xhost +local:docker > /dev/null

# Arguments to run container
args=(
    --rm    # autoremove the container
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
    ## SSH forwarding based on user spoofing, test ssh with
    ## ssh -T git@github.com
    --volume="$(dirname ${SSH_AUTH_SOCK}):$(dirname ${SSH_AUTH_SOCK}):ro"
    --env "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
	--volume="$HOME/.gitconfig:/home/${USERNAME}/.gitconfig:ro"
    
    # PID exposure

    # Workspace
    --volume="$(dirname ${ENTERPOINT_DIR}):${WORKSPACE_PATH}"   # Volume the parent of this docker repo to workspace
    --workdir "${WORKSPACE_PATH}"                               # cd the volumed workspace
    --env "WORKSPACE_PATH=${WORKSPACE_PATH}"
)

if [ "${use_realtime}" = 'true' ]; then
    args+=(
        # Realtime Kernel, if you are in RTkernel, uncomment the followings
        --privileged
        --cap-add=SYS_NICE
        --volume="${ENTERPOINT_DIR}/configs/limits.conf:/etc/security/limits.conf:ro"
    )
fi

args+=(
    # start image
    "${IMAGE_TAG}"
    "${sh}"
)

# Create container if not
if [ -z "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "\e[33mCONTAINER ${CONTAINER_NAME} not existing. Create and run the container\e[0m"
    docker run "${args[@]}"
else
    # Start the stopped container
    if [ -z "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo -e "\e[33mCONTAINER ${CONTAINER_NAME} existing but stopped. Start and run the container\e[0m"
        docker start ${CONTAINER_NAME}
        docker exec --interactive --tty \
                    --user="${USER_ID}:${GROUP_ID}" \
                    --workdir "${WORKSPACE_PATH}"  \
                    "${CONTAINER_NAME}" "${sh}"
    # Enter to a runnning container
    else
        echo -e "\e[33mCONTAINER ${CONTAINER_NAME} existing and running. Enter the container with a new section\e[0m"
        docker exec --interactive --tty \
                    --user="${USER_ID}:${GROUP_ID}" \
                    --workdir "${WORKSPACE_PATH}" \
                    "${CONTAINER_NAME}" "${sh}"
    fi
fi