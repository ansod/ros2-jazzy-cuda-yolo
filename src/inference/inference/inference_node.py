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
        img = cv.imread('/ws/image.png')
        results = self.model(img)
        for r in results:
            for box in r.boxes:

                coordinates = (box.xyxy).tolist()[0]
                label = results[0].names[int(box.cls)]

                left, top, right, bottom = int(coordinates[0]), int(coordinates[1]), int(coordinates[2]), int(coordinates[3])

                cv.rectangle(img, (left, top), (right, bottom), (255, 0, 0), 2)
                cv.putText(img, label, (right + 5, (top + bottom) // 2), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

        cv.imwrite('/ws/result.png', img)

        return response


def main(args=None):
    rclpy.init(args=args)

    node = InferenceNode()

    rclpy.spin(node)

    rclpy.shutdown()


if __name__ == '__main__':
    main()
