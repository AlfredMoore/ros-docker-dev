FROM osrf/ros:humble-desktop-full

######################################################################
### Ubuntu Essentials ################################################
######################################################################
# Development Tools
RUN apt update && apt install --yes \
    # Programming
    build-essential gcc g++ gdb cmake \
    software-properties-common \
    # Editor
    nano vim \
    # Repository
    git

# Productivity Tools.
RUN apt update && apt install --yes \
    # Network
    iproute2 iputils-ping net-tools openssh-client\
    # Download
    curl wget \
    # Compression
    unzip zip \
    # USB
    usbutils libusb-dev libudev-dev udev\
    # Graphics
    mesa-utils \
    # Terminal
    tmux zsh

# Python Tools
# RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update && apt-get install --yes \
    python-is-python3 \
    python3-colcon-common-extensions \
    python3-pip
# RUN pip3 install --upgrade virtualenv
# RUN apt-get update && apt-get install --yes \
#     python3.9 python3.9-dev python3.9-distutils python3.9-venv \
#     python3.10 python3.10-dev python3.10-distutils python3.10-venv
### End ##############################################################
######################################################################

######################################################################
### ROS ##############################################################
######################################################################
# Dependencies
# RUN apt install --yes \
    # ros-humble-joint-state-publisher-gui  # invalid somehow

# Environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
# RUN echo "export ROS_DOMAIN_ID=<your_domain_id>" >> ~/.bashrc # Default: 0
# RUN echo "export ROS_LOCALHOST_ONLY=1" >> ~/.bashrc # Default: 0
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

### End ##############################################################
######################################################################


# ######################################################################
# ### User Spoofing ####################################################
# ######################################################################
# # Create User and Group with passed ARG in .hcl file
# RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
#     useradd -u ${USER_ID} -g ${GROUP_ID} \
#         --create-home \
#         --shell /bin/bash \
#         ${USERNAME}

# # Setup HOME dir
# ENV HOME=/home/${USERNAME}
# WORKDIR ${HOME}
# ### End ##############################################################
# ######################################################################

# Editable from now
# ######################################################################
# ### Git ##############################################################
# ######################################################################
# USER ${USERNAME}
# # SSH forward is only valid to root, so we should specify it owned by uid
# # Befofre ssh frowarding, you should firstlt ssd-add your key to ssh agent
# RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
# RUN --mount=type=ssh,uid=${USER_ID} \
#     git clone git@github.com:<>/<>.git
# ### End ##############################################################
# ######################################################################