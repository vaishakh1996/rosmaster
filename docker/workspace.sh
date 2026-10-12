
#!/bin/bash
set -euo pipefail

# ROS 2 Humble CPU-only workspace setup
ROS_DISTRO=humble
ROS_WS=/home/rosmaster/ros2_ws

echo "Setting up ROS 2 ${ROS_DISTRO} workspace..."

# Load ROS 2 Humble environment
# ROS setup scripts may reference unset environment variables.
set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u

# Ensure workspace exists
mkdir -p "${ROS_WS}/src"
cd "${ROS_WS}"

# Verify required build tool
if ! command -v colcon >/dev/null 2>&1; then
    echo "ERROR: colcon is not installed."
    exit 1
fi

# Check for ROS packages
if [ -z "$(find src -name package.xml -print -quit)" ]; then
    echo "No ROS packages found in src."
    echo "Skipping workspace build."
    exit 0
fi

# Build packages using the non-root user
echo "Building ROS 2 workspace..."
colcon build --symlink-install

echo "Workspace build completed."

echo "To load the workspace in your current shell, run:"
echo "source ${ROS_WS}/install/setup.bash"
