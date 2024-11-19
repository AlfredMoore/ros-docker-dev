#! /usr/bin/env bash

set -o errexit
set -o nounset

source ./env.sh

# Parse flags
no_cache='false'
use_bash='false'
use_realtime='false'

while getopts 'nbr' flag; do
  case "${flag}" in
    n) no_cache='true' ;;
    b) use_bash='true' ;;
    r) use_realtime='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

if [ "${no_cache}" = 'true' ]; then
    echo -e "Use \e[33mno cache\e[0m to build or rebuild the image"
    export NOCACHE=true
else
    echo -e "Use \e[33mcache\e[0m to build or rebuild the image"
    export NOCACHE=false
fi

if [ "${use_realtime}" = 'true' ]; then
    echo -e "Enable \e[33mRealtime\e[0m Kernel"
    use_bash='true'
    echo "Realtime program only supports bash and root user now."
    export HOME_PATH="/root"
    export WORKSPACE_PATH="/root/workspace"
    echo "Override HOME_PATH=${HOME_PATH}, WORKSPACE_PATH=${WORKSPACE_PATH}"
    user="root"
else
    user="${USER_ID}:${GROUP_ID}"
    echo -e "Only Use \e[33mNormal\e[0m Kernel"
fi

if [ "${use_bash}" = 'true' ]; then
    echo -e "Use \e[33mbash\e[0m as the shell"
    sh="/bin/bash"
else
    echo -e "Use \e[33mzsh\e[0m as the shell"
    sh="/bin/zsh"
fi

#############################################################


# build image if not
if ! docker inspect "${IMAGE_TAG}" --type=image &> /dev/null; then
    echo -e "IMAGE \e[33m${IMAGE_TAG}\e[0m not existing, \e[33mBUILDING\e[0m IMAGE ${IMAGE_TAG}..."
    docker buildx bake -f panda-bake.hcl
    echo -e "Image Built \e[33mSucessfully\e[0m"
else
    echo -e "IMAGE \e[33m${IMAGE_TAG}\e[0m already existing..."
    if [ "${no_cache}" = 'true' ]; then
        echo -e "Detect \e[33mno cache\e[0m true, \e[33mREBUILDING\e[0m the image"
        docker buildx bake -f panda-bake.hcl
        echo -e "Image Built \e[33mSucessfully\e[0m"
    fi
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
    --user="${user}"      # Align with Dockerfile
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
    --env "SHELL=${sh}"
    "${IMAGE_TAG}"
    "${sh}"
)

# Create container if not
if [ -z "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "CONTAINER \e[33m${CONTAINER_NAME}\e[0m not existing. \e[33mNew\e[0m is created and run"
    docker run "${args[@]}"
else
    # Start the stopped container
    if [ -z "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
        echo -e "CONTAINER \e[33m${CONTAINER_NAME}\e[0m existing but stopped. \e[33mContinue\e[0m the stopped container"
        docker start ${CONTAINER_NAME}
        docker exec --interactive --tty \
                    --user="${user}" \
                    --workdir "${WORKSPACE_PATH}"  \
                    "${CONTAINER_NAME}" "${sh}"
    # Enter to a runnning container
    else
        echo -e "CONTAINER \e[33m${CONTAINER_NAME}\e[0m existing and running. \e[33mEnter\e[0m the container with a new section"
        docker exec --interactive --tty \
                    --user="${user}" \
                    --workdir "${WORKSPACE_PATH}" \
                    "${CONTAINER_NAME}" "${sh}"
    fi
fi