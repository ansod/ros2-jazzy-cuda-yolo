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

COPY test_image.png image.png
COPY inference.py inference.py
COPY entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]

CMD ["python3", "inference.py"]