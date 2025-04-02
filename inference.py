import cv2 as cv
import torch
from ultralytics import YOLO

MODEL_PATH = "yolov8n.pt"
IMAGE_PATH = "image.png"

print(f'CUDA available: {torch.cuda.is_available()}')

model = YOLO(MODEL_PATH).to('cuda')
img = cv.imread(IMAGE_PATH)

results = model(img)
