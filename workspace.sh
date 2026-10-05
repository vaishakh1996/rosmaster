#!/bin/bash
set -e

# Set ROS 2 distribution as a variable
ROS_DISTRO="humble"

# Source ROS 2 setup
source /opt/ros/$ROS_DISTRO/setup.bash

# Install system dependencies
apt-get update && apt-get install -y \
    gnupg \
    curl \
    libpcap-dev

# Navigate to the workspace
cd /home/rosmaster/ros2_ws

# Install ROS 2 dependencies for all packages
echo "Installing ROS 2 dependencies..."
rosdep update
rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

# Build the workspace
echo "Building packages..."
colcon build
source install/setup.bash

echo "Workspace setup completed!"