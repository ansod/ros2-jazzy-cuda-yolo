#!/bin/bash

source /opt/ros/${ROS_DISTRO}/setup.bash
source /ws/install/setup.bash

ros2 run inference inference_node &

ros2 service call /inference std_srvs/srv/Empty "{}"

exec "$@"
