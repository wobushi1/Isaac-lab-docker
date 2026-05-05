# Isaac Lab / Isaac Sim + ROS 2 镜像构建包

机器人训练平台镜像包。

这个目录用于构建一个新的 Docker 镜像：

```text
NVIDIA 官方 Isaac Lab 或 Isaac Sim 镜像 + ROS 2 Humble
```

默认底座：

```text
nvcr.io/nvidia/isaac-lab:2.1.0
```

也可以切换为：

```text
nvcr.io/nvidia/isaac-sim:4.5.0
```

## 1. 适用场景

适合公司内网平台沉淀一个机器人仿真基础镜像：

1. Isaac Sim / Isaac Lab 后台仿真。
2. Isaac Lab headless 训练。
3. 容器内使用 ROS 2 命令，例如 `ros2 topic list`。
4. Isaac Sim ROS 2 Bridge 与外部 ROS 2 节点通信。

这个包不包含 Jupyter。如果后续要接公司 Notebook 平台，可以在这个镜像基础上继续叠加 JupyterHub / JupyterLab 启动层。

## 2. 前置条件

构建和运行机器需要：

1. Linux x86_64。
2. NVIDIA GPU。
3. NVIDIA Driver。
4. Docker。
5. NVIDIA Container Toolkit。
6. 可访问 NVIDIA NGC 镜像仓库，或者已经把官方镜像同步到内网仓库。

先验证 GPU 容器能力：

```bash
docker run --rm --gpus all ubuntu nvidia-smi
```

## 3. NGC 登录

如果服务器能访问外网 NGC，先登录：

```bash
docker login nvcr.io
```

用户名通常填：

```text
$oauthtoken
```

密码填 NGC API Key。

## 4. 构建默认镜像

进入本目录：

```bash
cd isaac-lab-ros2-image
```

构建：

```bash
./scripts/build.sh
```

默认生成：

```text
isaac-lab-ros2:2.1.0-humble
```

等价的原始命令：

```bash
docker build \
  --build-arg BASE_IMAGE=nvcr.io/nvidia/isaac-lab:2.1.0 \
  --build-arg ROS_DISTRO=humble \
  -t isaac-lab-ros2:2.1.0-humble \
  .
```

## 4.1 直接使用打好的镜像

如果你拿到的不是源码构建流程，而是一个已经导出的 Docker 镜像文件，例如：

```text
isaac-lab-ros2-2.1.0-humble.tar
```

先导入本地：

```bash
docker load -i isaac-lab-ros2-2.1.0-humble.tar
```

导入完成后，就可以直接跳到“本地运行”或“镜像冒烟测试”章节继续使用，不需要重新执行 `./scripts/build.sh`。

如果别人提供的是镜像仓库地址，而不是 `tar` 文件，也可以直接拉取：

```bash
docker pull <registry/image:tag>
```

然后同样按下面的运行和测试步骤继续。

## 5. 切换为 Isaac Sim 底座

如果只想基于 Isaac Sim 官方镜像，不使用 Isaac Lab 官方镜像：

```bash
BASE_IMAGE=nvcr.io/nvidia/isaac-sim:4.5.0 \
IMAGE_NAME=isaac-sim-ros2 \
IMAGE_TAG=4.5.0-humble \
./scripts/build.sh
```

生成：

```text
isaac-sim-ros2:4.5.0-humble
```

## 6. 本地运行

进入交互式 bash：

```bash
./scripts/run-bash.sh isaac-lab-ros2:2.1.0-humble
```

或者直接运行：

```bash
docker run --rm -it \
  --gpus all \
  --network host \
  -e ACCEPT_EULA=Y \
  -e PRIVACY_CONSENT=Y \
  isaac-lab-ros2:2.1.0-humble \
  bash
```

建议测试 ROS 2：

```bash
ros2 topic list
python3 -c "import rclpy; print('rclpy OK')"
```

建议测试 Isaac Python：

```bash
/isaac-sim/python.sh -c "import torch; print(torch.cuda.is_available())"
```

## 7. 镜像冒烟测试

```bash
./scripts/test-image.sh isaac-lab-ros2:2.1.0-humble
```

测试内容：

1. 容器内能看到 NVIDIA GPU。
2. ROS 2 命令可用。
3. `rclpy` 可导入。
4. Isaac Sim Python 可用。
5. PyTorch 能识别 CUDA。

## 8. 推送到公司内网仓库

示例：

```bash
./scripts/push-internal.sh registry.example.com/robotics/isaac-lab-ros2:2.1.0-humble
```

等价命令：

```bash
docker tag isaac-lab-ros2:2.1.0-humble registry.example.com/robotics/isaac-lab-ros2:2.1.0-humble
docker push registry.example.com/robotics/isaac-lab-ros2:2.1.0-humble
```

## 9. 平台运行参数建议

平台启动任务时，需要保证：

```bash
--gpus all
--network host
-e ACCEPT_EULA=Y
-e PRIVACY_CONSENT=Y
```

ROS 2 依赖 DDS 自动发现。测试阶段建议使用 `--network host`，这样最省事。后续如果平台不能用 host 网络，需要单独规划 DDS 发现、端口和跨容器通信。

## 10. 镜像里已经包含什么

默认镜像包含：

1. NVIDIA 官方 Isaac Lab 2.1.0。
2. Isaac Sim 4.5.0 运行时。
3. ROS 2 Humble `ros-base`。
4. ROS 2 demo nodes。
5. `rclpy`、`ros2` 命令行。
6. `colcon`、`rosdep`、`vcstool`。
7. 自动 source ROS 2 环境的 entrypoint。

## 11. 注意事项

1. 不建议从普通 ROS 2 镜像反向安装 Isaac Sim，因为 Isaac Sim 依赖复杂、镜像体积大、失败率高。
2. 推荐从 NVIDIA 官方 Isaac Lab / Isaac Sim 镜像开始，再装 ROS 2。
3. Isaac Lab 官方镜像主要用于 headless training，不适合直接打开完整 GUI。
4. 需要可视化时，需要额外配置 Isaac Sim Streaming / WebRTC 或图形桌面环境。
5. 如果公司内网不能访问外网，需要先把 `nvcr.io/nvidia/isaac-lab:2.1.0` 或 `nvcr.io/nvidia/isaac-sim:4.5.0` 同步到内网仓库，再修改 `BASE_IMAGE`。

## 12. 内网底座示例

如果官方镜像已经同步到内网，例如：

```text
registry.example.com/nvidia/isaac-lab:2.1.0
```

可以这样构建：

```bash
BASE_IMAGE=registry.example.com/nvidia/isaac-lab:2.1.0 \
IMAGE_NAME=isaac-lab-ros2 \
IMAGE_TAG=2.1.0-humble \
./scripts/build.sh
```

## 13. 参考资料

1. Isaac Sim 4.5 Container Installation: https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/install_container.html
2. Isaac Sim 4.5 ROS 2 Installation: https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/install_ros.html
3. Isaac Lab 2.1 Docker Guide: https://isaac-sim.github.io/IsaacLab/v2.1.0/source/deployment/docker.html
