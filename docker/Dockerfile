
# ROS 2 Humble - CPU-only development environment
ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}-ros-base

LABEL maintainer="rosmaster"

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV LIBGL_ALWAYS_SOFTWARE=1

SHELL ["/bin/bash", "-c"]

# Install development tools and ROS packages as root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    curl \
    git \
    libpcap-dev \
    nano \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    ros-humble-demo-nodes-cpp \
    ros-humble-demo-nodes-py \
    ros-humble-joint-state-publisher-gui \
    ros-humble-rviz2 \
    ros-humble-xacro \
    && rm -rf /var/lib/apt/lists/*

# Create non-root development user
ARG USERNAME=rosmaster
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} \
    --gid ${USER_GID} \
    --create-home \
    --shell /bin/bash ${USERNAME}

# Create ROS 2 workspace
RUN mkdir -p /home/${USERNAME}/ros2_ws/src && \
    mkdir -p /home/${USERNAME}/shared/ros2 && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/ros2_ws /home/${USERNAME}/shared

# Copy existing project scripts
COPY --chown=${USERNAME}:${USERNAME} docker/workspace.sh /home/${USERNAME}/workspace.sh
COPY --chown=${USERNAME}:${USERNAME} docker/entrypoint.sh /home/${USERNAME}/entrypoint.sh
COPY --chown=${USERNAME}:${USERNAME} docker/bash_aliases.txt /home/${USERNAME}/.bash_aliases

RUN chmod +x /home/${USERNAME}/workspace.sh \
    /home/${USERNAME}/entrypoint.sh

# Configure interactive shell
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc && \
    echo 'if [ -f ~/ros2_ws/install/setup.bash ]; then source ~/ros2_ws/install/setup.bash; fi' \
    >> /home/${USERNAME}/.bashrc && \
    echo 'source ~/.bash_aliases' >> /home/${USERNAME}/.bashrc

# Default ROS environment
ENV ROS_DOMAIN_ID=42
ENV ROS_LOCALHOST_ONLY=1

# Run as unprivileged user
USER ${USERNAME}
WORKDIR /home/${USERNAME}/ros2_ws

# Do not build workspace automatically during image creation
# Workspace build will be performed explicitly after startup

ENTRYPOINT ["/home/rosmaster/entrypoint.sh"]
CMD ["/bin/bash"]
