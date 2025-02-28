# Editable ROS Docker Development

<!-- You could also check the latest [main branch README.md](https://github.com/AlfredMoore/ros-docker-dev/blob/main/README.md) -->

## Prerequisites
You should firstly install [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) on your Ubuntu. Then [manage docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user), to enable `docker` instead of `sudo docker`.

 * NOTE: Do not install Docker Desktop. It is different from the Docker Engine and not so friendly to docker development.

## How to use ( two methods )
This is the cleaned up version. All Options should be defined in config file `env.sh` and `enterpoint.sh` as Environment Variables or by using `export <VAR>=...`.

### Running Options
Env override options:
 * ROS_DISTRO: choose ROS distribution. 
 ```bash
 export ROS_DISTRO=humble   # or export ROS_DISTRO=noetic
 ```
 * VOLUME_DIR: volume a folder into container dir `/workspace`.
 ```bash
 export VOLUME_DIR=<path>   # or export VOLUME_DIR=$(pwd)
 ```
 * CUDA: Follow these links to use Nvidia Cuda in container and solve potential problems.
    * [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
    * [Error: Failed to initialize NVML: Unknown Error](https://bobcares.com/blog/docker-failed-to-initialize-nvml-unknown-error/)
 ```bash
 export CUDA=1              # or unset CUDA
 ```

### Method 1: Enter Container with Scripts
In the repository folder, run
```bash
./enterpoint.sh
```

Here is env variables in the `env.sh`. Define those in the `env.sh` or your env variable will be override by the `env.sh`.
 * GIT_LABEL
 * IMAGE_TAG
 * CONTAINER_NAME
 * HOME_PATH
 * WORKSPACE_PATH

### Method 2: Enter Container without CLI
Build Image: 
```bash
docker build --tag <image tag> --file <dockerfile> --no-cache .     # --no-cache means install dependencies with no cache
```

Run Container:
```bash
docker run --rm -it --name=<CONTAINER_NAME> --network=<net> --privileged --volume="<host path>:<path>" --device=="<host path>:<path>" --env="<var=host var>"
```

Execute cmd:
```bash
docker build -it <CONTAINER_NAME> <CMD/SHELL>
```

### How To Rebuild Image:
```bash
source env.sh
docker build --tag "${IMAGE_TAG}" --file "ros-${ROS_DISTRO}.Dockerfile" --no-cache .
```

## In ROS Humble
~~Source environment. These lines can be added to `~/.bashrc` or `~/.zshrc` for convenience.~~
The following commands have been added to humble dockerfile and will be added to `.bashrc`.
```bash
source /opt/ros/humble/setup.bash
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
```

After compiling, don't forget to source setup file
```bash
colcon build --symlink-install
source install/setup.bash
```