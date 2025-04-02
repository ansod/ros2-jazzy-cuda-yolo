#FROM ubuntu:24.04 as base
FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 as base

RUN apt update && apt install -y --no-install-recommends \
    wget \
    python3-pip \
    python3-venv \
    python3-opencv \
    software-properties-common \
    sudo \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PYTHONPATH="$VIRTUAL_ENV/lib/python3.12/site-packages:$PYTHONPATH"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install ultralytics opencv-python && rm -rf /root/.cache/pip

ENV ROS_DISTRO=jazzy

# Install ROS2
RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt update && apt install -y --no-install-recommends \
    ros-${ROS_DISTRO}-ros-base \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --force-reinstall colcon-core \
    && rm -rf /root/.cache/pip
RUN pip install colcon-common-extensions \
    && rm -rf /root/.cache/pip
RUN pip install empy==3.3.4 lark catkin_pkg \
    && rm -rf /root/.cache/pip

# Build and install packages
RUN mkdir -p /ws/install
RUN mkdir -p /ws/build

COPY src/inference /ws/src/inference
WORKDIR /ws
SHELL ["/bin/bash", "-c"]
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build --symlink-install

COPY test_image.png image.png
#COPY inference.py inference.py
COPY entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
