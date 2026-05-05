#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-isaac-lab-ros2:2.1.0-humble}"

docker run --rm \
  --gpus all \
  --network host \
  -e ACCEPT_EULA=Y \
  -e PRIVACY_CONSENT=Y \
  "${IMAGE}" \
  bash -lc '
    set -euo pipefail
    echo "== NVIDIA GPU =="
    nvidia-smi

    echo "== ROS 2 =="
    # ROS setup scripts are not consistently compatible with nounset.
    set +u
    source /opt/ros/${ROS_DISTRO}/setup.bash
    set -u
    ros2 --help >/dev/null
    python3 -c "import rclpy; print(\"rclpy import OK\")"

    echo "== Isaac Python =="
    if [ -x /isaac-sim/python.sh ]; then
      /isaac-sim/python.sh -c "import torch; print(\"torch cuda available:\", torch.cuda.is_available())"
    else
      echo "/isaac-sim/python.sh not found"
      exit 1
    fi

    echo "Image smoke test passed"
  '
