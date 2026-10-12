# ROS 2 Humble — CPU-Only Docker

Development environment for the ROSMASTER M3 Pro project.

**Stack:** ROS 2 Humble · Ubuntu 22.04 container · Gazebo Fortress 6 · Mesa llvmpipe (CPU rendering)

## 1. Requirements

- Linux x86_64 host with Docker and Docker Compose.
- For graphical applications: an X11/XWayland desktop with `DISPLAY` and `XAUTHORITY` configured.
- Host user UID/GID `1000` recommended for repository file permissions.

## 2. Build the Image

Run from the repository root on the host:

```bash
bash docker/build.sh
```

Image: `rosmaster:humble-cpu-only`

## 3. Start and Stop

```bash
# Start the container
docker compose -f docker/docker-compose.yml up -d --no-build manipulation

# Open a shell
docker exec -it manipulation_cpu bash

# Stop the container
docker compose -f docker/docker-compose.yml down
```

Inside the container, initialize ROS if needed:

```bash
source /opt/ros/humble/setup.bash
```

## 4. Common Commands

Run inside the container:

```bash
# Check ROS
ros2 --version

# Build ROS packages if any exist
/home/rosmaster/workspace.sh

# Start Gazebo GUI (empty world)
LIBGL_ALWAYS_SOFTWARE=1 QT_QPA_PLATFORM=xcb ign gazebo empty.sdf

# Check CPU-based graphics renderer
glxinfo -B
```

The repository is mounted at:

`/home/rosmaster/ros2_ws/src`

## 5. Important Notes

- The container runs as non-root user `rosmaster`.
- CPU rendering is enabled; no NVIDIA GPU runtime is required.
- The container is not privileged and does not mount robot hardware devices.
- X11 socket and authentication mounts are read-only.
- Do not replace or overwrite the separate `rosmaster:latest` image.
- The Docker image does **not** contain a permanent copy of the source repository; the source is bind-mounted.
- After a desktop login change, recreate the container if the Xauthority file path has changed.
- The current Compose configuration requires a graphical desktop session. Headless use needs a separate configuration.
- `ROS_LOCALHOST_ONLY=1` restricts ROS communication to the local host; adjust intentionally for multi-PC ROS communication.

## 6. Using Another PC

For a similar Ubuntu x86_64 desktop, clone the repository, install Docker and Compose, and rebuild the image with `bash docker/build.sh`.

Before starting, verify:

- `echo "$DISPLAY"` and `echo "$XAUTHORITY"` return valid values.
- `/tmp/.X11-unix` exists.
- Host UID/GID matches the container user or repository permissions are handled appropriately.

An ARM64 PC or Jetson requires a compatible ARM64 image and separate verification. Do not assume this x86_64 image will run unchanged.

**Validated baseline:** ROS 2 communication, Gazebo Fortress GUI, ROS–Gazebo `/clock` bridge, and Mesa llvmpipe CPU rendering.