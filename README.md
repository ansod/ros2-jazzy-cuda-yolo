# Run Ultralytics YOLO model with CUDA and ROS2 Jazzy in Docker

Dockerfile based on nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 and includes installations of ultralytics, opencv-python and ROS2 Jazzy.

## How to test

Build docker image:
```bash
docker build -t test_inference .
```

Run docker container that tests inference:

If on ARM system (install [Nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))
```bash
docker run --runtime nvidia --name test_inference test_inference
```
or if on x86 system
```bash
docker run --gpus all --name test_inference test_inference
```

Copy result image from container to view result:
```bash
docker cp test_inference:/ws/result.png result.png
open result.png
```