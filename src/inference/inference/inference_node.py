import rclpy
from rclpy.node import Node
import torch
import cv2 as cv
from ultralytics import YOLO

from std_srvs.srv import Empty


class InferenceNode(Node):
    def __init__(self) -> None:
        super().__init__('inference_node')
        self.srv = self.create_service(Empty, 'inference', self.inference_callback)

        self.get_logger().info(f"CUDA available: {torch.cuda.is_available()}")
        self.model = YOLO('yolov8n.pt').to('cuda')

    def inference_callback(self, request, response):
        img_path = cv.imread('/ws/image.png')
        _ = self.model(img_path)
        return response


def main(args=None):
    rclpy.init(args=args)

    node = InferenceNode()

    rclpy.spin(node)

    rclpy.shutdown()


if __name__ == '__main__':
    main()
