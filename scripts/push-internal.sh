#!/usr/bin/env bash
set -euo pipefail

LOCAL_IMAGE="${LOCAL_IMAGE:-isaac-lab-ros2:2.1.0-humble}"
INTERNAL_IMAGE="${1:-}"

if [ -z "${INTERNAL_IMAGE}" ]; then
  echo "Usage: $0 <internal-registry/image:tag>" >&2
  echo "Example: $0 registry.example.com/robotics/isaac-lab-ros2:2.1.0-humble" >&2
  exit 2
fi

docker tag "${LOCAL_IMAGE}" "${INTERNAL_IMAGE}"
docker push "${INTERNAL_IMAGE}"

echo "Pushed image: ${INTERNAL_IMAGE}"
