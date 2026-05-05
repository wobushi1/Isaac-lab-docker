#!/usr/bin/env bash
set -e

if [ -n "${ROS_DISTRO:-}" ] && [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
  # shellcheck disable=SC1090
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi

if [ -f "/workspace/ros_ws/install/setup.bash" ]; then
  # shellcheck disable=SC1091
  source "/workspace/ros_ws/install/setup.bash"
fi

exec "$@"
