#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-isaac-lab-ros2:2.1.0-humble}"

docker run --rm -it \
  --gpus all \
  --network host \
  -e ACCEPT_EULA=Y \
  -e PRIVACY_CONSENT=Y \
  -v "${PWD}:/workspace/host:rw" \
  "${IMAGE}" \
  bash
