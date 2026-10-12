#!/bin/bash
set -e

# ROS 2 Humble CPU-only container entrypoint

ROS_DISTRO=humble
ROS_WS=/home/rosmaster/ros2_ws

# Create user runtime directory
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# Load ROS 2 Humble
source "/opt/ros/${ROS_DISTRO}/setup.bash"

# Load workspace overlay if previously built
if [ -f "${ROS_WS}/install/setup.bash" ]; then
    source "${ROS_WS}/install/setup.bash"
fi

# Configure ROS networking for local CPU-only development
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-42}"
export ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY:-1}"

echo "ROS 2 ${ROS_DISTRO} environment initialized."
echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
echo "ROS_LOCALHOST_ONLY=${ROS_LOCALHOST_ONLY}"

# Do not build the workspace automatically.
# Use workspace.sh explicitly when needed.

exec "$@"
