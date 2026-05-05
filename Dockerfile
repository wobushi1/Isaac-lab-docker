# syntax=docker/dockerfile:1

# Default: Isaac Lab official image, suitable for headless training.
# You can override it with:
#   --build-arg BASE_IMAGE=nvcr.io/nvidia/isaac-sim:4.5.0
ARG BASE_IMAGE=nvcr.io/nvidia/isaac-lab:2.1.0
FROM ${BASE_IMAGE}

ARG ROS_DISTRO=humble
ARG DEBIAN_FRONTEND=noninteractive

ENV ACCEPT_EULA=Y \
    PRIVACY_CONSENT=Y \
    ROS_DISTRO=${ROS_DISTRO} \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
        locales \
        lsb-release \
        software-properties-common \
        sudo \
        tzdata \
        vim \
        wget \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN source /etc/os-release \
    && if [[ "${VERSION_CODENAME}" != "jammy" ]]; then \
        echo "ROS 2 Humble expects Ubuntu 22.04 jammy, but base image is ${VERSION_CODENAME}." >&2; \
        exit 1; \
    fi \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu ${VERSION_CODENAME} main" \
        > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-ros-base \
        ros-${ROS_DISTRO}-demo-nodes-cpp \
        ros-${ROS_DISTRO}-demo-nodes-py \
        python3-argcomplete \
        python3-colcon-common-extensions \
        python3-pip \
        python3-rosdep \
        python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true \
    && rosdep update || true

RUN printf '%s\n' \
        "source /opt/ros/${ROS_DISTRO}/setup.bash" \
        "export ROS_DISTRO=${ROS_DISTRO}" \
        "export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION}" \
        > /etc/profile.d/ros2.sh \
    && printf '%s\n' \
        "" \
        "# ROS 2 environment" \
        "source /opt/ros/${ROS_DISTRO}/setup.bash" \
        "export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION}" \
        >> /etc/bash.bashrc

COPY entrypoint.sh /usr/local/bin/isaac-ros-entrypoint.sh
RUN chmod +x /usr/local/bin/isaac-ros-entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/isaac-ros-entrypoint.sh"]
CMD ["bash"]
