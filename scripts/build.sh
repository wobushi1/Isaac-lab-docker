#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

BASE_IMAGE="${BASE_IMAGE:-nvcr.io/nvidia/isaac-lab:2.1.0}"
ROS_DISTRO="${ROS_DISTRO:-humble}"
IMAGE_NAME="${IMAGE_NAME:-isaac-lab-ros2}"
IMAGE_TAG="${IMAGE_TAG:-2.1.0-humble}"

docker build \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  --build-arg "ROS_DISTRO=${ROS_DISTRO}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  "${ROOT_DIR}"

echo "Built image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Base image: ${BASE_IMAGE}"
echo "ROS distro: ${ROS_DISTRO}"
