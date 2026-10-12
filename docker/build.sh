
#!/bin/bash
set -euo pipefail

# ROS 2 Humble - CPU-only Docker build script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"

IMAGE_NAME="rosmaster:humble-cpu-only"

echo "======================================="
echo " ROS 2 Humble - CPU-only Docker Build"
echo "======================================="
echo "Project: ${PROJECT_ROOT}"
echo "Image:   ${IMAGE_NAME}"

# Verify Docker availability
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not accessible."
    exit 1
fi

# Verify Docker Compose availability
if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose is not available."
    exit 1
fi

# Build using the existing Compose configuration
cd "${PROJECT_ROOT}"

docker compose \
    -f docker/docker-compose.yml \
    build manipulation

echo ""
echo "Docker build completed successfully."
echo "Image: ${IMAGE_NAME}"
