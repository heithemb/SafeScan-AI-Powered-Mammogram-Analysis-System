import numpy as np
import cv2
import matplotlib.pyplot as plt
from PIL import Image
import torch
import io
CUSTOM_CLASSES = ['calc', 'mass']

def process_predictions(image_path: str, predictions: dict, confidence_threshold=0.5):
    try:
        """
        Visualize predictions (boxes, masks, labels) on an image from a file path.

        Args:
        image_path (str): Path to the image file.
        predictions (dict): Dict with 'boxes', 'labels', 'scores', and 'masks' from the model.
        confidence_threshold (float): Confidence threshold for filtering predictions.

        Returns:
            np.ndarray: Annotated prediction image in RGB format.
        """
        # Load and convert image to numpy array
        img = Image.open(image_path).convert("RGB")
        image_np = np.array(img)

        if image_np.max() <= 1:
            image_np = (image_np * 255).astype(np.uint8)

        pred_image = image_np.copy()
        # Convert tensors to numpy and filter by confidence
        boxes = torch.tensor(predictions['boxes'])
        labels = torch.tensor(predictions['labels'])
        scores = torch.tensor(predictions['scores'])
        masks = torch.tensor(predictions['masks'])
        classif = predictions['classification']  # Get classification results
        high_conf = scores > confidence_threshold
        boxes = boxes[high_conf].numpy()
        
        labels = labels[high_conf].numpy()
        scores = scores[high_conf].numpy()
        masks = masks[high_conf].numpy()
        high_conf = high_conf.cpu().numpy()  # Convert tensor to numpy array
        classif = [cls for cls, mask in zip(classif, high_conf) if mask]# Filter by confidence for classif
    except Exception as e:
        print(f"Error: {e}")
        raise


    for i, (box, label, class_result) in enumerate(zip(boxes, labels, classif)):
        xmin, ymin, xmax, ymax = map(int, box)
        # Draw bounding box
        cv2.rectangle(pred_image, (xmin, ymin), (xmax, ymax), (147, 20, 255) , 2)

        # Add label and score
        class_name = CUSTOM_CLASSES[label - 1]
        # Get classification result if available

        label_text = f"{class_result} : {class_name} {scores[i]:.2f}"
        cv2.putText(pred_image, label_text, (xmin, ymin - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (147, 20, 255), 2)

        # Draw mask
        mask = masks[i].squeeze()
        mask = (mask > 0.5).astype(np.uint8)

        colored_mask = np.zeros_like(pred_image)
        colored_mask[:, :] = (255, 0, 0)
        pred_image = np.where(mask[..., None] > 0,  cv2.addWeighted(pred_image, 1, colored_mask, 0.3, 0), pred_image)

        # Draw contour edges
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(pred_image, contours, -1, (0, 255, 255), 2)

    # Convert BGR to RGB for matplotlib
    pred_image = cv2.cvtColor(pred_image, cv2.COLOR_BGR2RGB)
    _, buffer = cv2.imencode('.png', pred_image)
    image_stream = io.BytesIO(buffer)
    image_stream.seek(0)  # Don't forget this
    return image_stream


