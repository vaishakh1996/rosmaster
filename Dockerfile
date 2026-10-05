# Set the ROS distribution as an argument, defaulting to 'humble'
ARG ROS_DISTRO=humble

# The base image comes from the official ROS repository hosted on Docker Hub
# You can find available ROS images here: https://hub.docker.com/_/ros/tags
# We're using the ros-base image which includes core ROS 2 packages
FROM ros:${ROS_DISTRO}-ros-base

# Set the maintainer information for this Dockerfile
LABEL maintainer="rosmaster"

# Set environment variables
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV DEBIAN_FRONTEND=noninteractive

# Set the default shell to bash for RUN commands
# This ensures all RUN commands use bash instead of sh
SHELL ["/bin/bash", "-c"]

# Update the system and install essential tools
# This step upgrades all packages and installs utilities needed for development
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq --no-install-recommends apt-utils wget curl git build-essential \
    vim sudo lsb-release locales bash-completion tzdata gosu gedit htop nano libserial-dev

# Install additional tools required for ROS 2 development
# These packages help with building and managing ROS 2 workspaces
RUN apt-get update -q && \
    apt-get install -y gnupg2 iputils-ping usbutils \
    python3-argcomplete python3-colcon-common-extensions python3-networkx python3-pip python3-rosdep python3-vcstool

# Create the 'rosmaster' user with sudo privileges
# Using a non-root user is best practice for daily development
ARG USERNAME=rosmaster
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up the ROS 2 environment for the rosmaster user
# This ensures that ROS 2 commands are available in the shell
# rosdep is a tool for installing system dependencies for ROS packages
RUN rosdep update && \
    grep -F "source /opt/ros/${ROS_DISTRO}/setup.bash" /home/${USERNAME}/.bashrc || echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USERNAME}/.bashrc && \
    grep -F "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" /home/${USERNAME}/.bashrc || echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/${USERNAME}/.bashrc

# Install additional ROS 2 packages
RUN apt-get update && \
    apt-get install -y \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-demo-nodes-cpp \
    ros-${ROS_DISTRO}-demo-nodes-py \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt-reconfigure

# Install Mesa graphics drivers
# Mesa is an open-source implementation of OpenGL and other graphics APIs
# It's crucial for 3D rendering in many applications, including RViz in ROS
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:kisak/kisak-mesa

# Create necessary directories owned by rosmaster
RUN mkdir -p /etc/udev/rules.d && \
    mkdir -p /home/${USERNAME}/ros2_ws/src && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/ros2_ws

# Copy the entire project into the container
# Since we're using the parent directory as context, we can copy everything
COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/ros2_ws/src

# Copy configuration files from docker directory
# Note the docker/ prefix since we're in the parent context
COPY docker/workspace.sh /home/${USERNAME}/
COPY docker/entrypoint.sh /home/${USERNAME}/
COPY docker/bash_aliases.txt /home/${USERNAME}/.bashrc_aliases

# Make scripts executable
RUN chmod +x /home/${USERNAME}/workspace.sh /home/${USERNAME}/entrypoint.sh && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/workspace.sh /home/${USERNAME}/entrypoint.sh /home/${USERNAME}/.bashrc_aliases

# Add custom bash aliases
RUN cat /home/${USERNAME}/.bashrc_aliases >> /home/${USERNAME}/.bashrc && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.bashrc

# Run the workspace setup script as rosmaster
# This typically installs workspace dependencies and builds the ROS 2 packages
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN ./workspace.sh

# Ensure the ROS 2 workspace is sourced in every new shell
RUN echo "source /home/${USERNAME}/ros2_ws/install/setup.bash" >> /home/${USERNAME}/.bashrc

# Set the entrypoint for the container
# This script will be run every time the container starts
ENTRYPOINT ["/home/rosmaster/entrypoint.sh"]

# Set the default command
# This keeps the container running indefinitely, allowing you to exec into it
CMD ["/bin/bash", "-c", "tail -f /dev/null"]