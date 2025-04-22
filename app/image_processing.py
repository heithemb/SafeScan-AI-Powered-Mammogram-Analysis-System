import base64
from fastapi.responses import JSONResponse
import numpy as np
import cv2
import matplotlib.pyplot as plt
from PIL import Image
import torch
import io

CUSTOM_CLASSES = ['calc', 'mass']

def calculate_lesion_features(mask, image_np, pixel_spacing=0.1):
    """Calculate comprehensive morphological and intensity features for a lesion."""
    mask = (mask > 0).astype(np.uint8)
    
    # Basic measurements
    area_px = cv2.countNonZero(mask)
    area_mm2 = area_px * (pixel_spacing ** 2)
    
    # Contour-based features
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return None
        
    largest_contour = max(contours, key=cv2.contourArea)
    perimeter_px = cv2.arcLength(largest_contour, True)
    perimeter_mm = perimeter_px * pixel_spacing
    
    # Shape characteristics
    circularity = (4 * np.pi * area_px) / (perimeter_px ** 2) if perimeter_px > 0 else 0
    
    eccentricity = 0
    if len(largest_contour) >= 5:
        ellipse = cv2.fitEllipse(largest_contour)
        a, b = ellipse[1][0]/2, ellipse[1][1]/2
        eccentricity = np.sqrt(1 - (min(a,b)**2 / max(a,b)**2))
    
    # Intensity features
    if len(image_np.shape) == 3:
        image_gray = cv2.cvtColor(image_np, cv2.COLOR_RGB2GRAY)
    else:
        image_gray = image_np
    
    masked_pixels = image_gray[mask > 0]
    mean_intensity = np.mean(masked_pixels)
    std_intensity = np.std(masked_pixels)
    
    return {
        'morphology': {
            'area_mm2': float(area_mm2),
            'perimeter_mm': float(perimeter_mm),
            'circularity': float(circularity),
            'eccentricity': float(eccentricity)
        },
        'intensity': {
            'mean': float(mean_intensity),
            'std_dev': float(std_intensity)
        }
    }

def process_predictions(image_path: str, predictions: dict, confidence_threshold=0.5, pixel_spacing=0.1):
    try:
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
        classif = predictions['classification']
        
        high_conf = scores > confidence_threshold
        boxes = boxes[high_conf].numpy()
        labels = labels[high_conf].numpy()
        scores = scores[high_conf].numpy()
        masks = masks[high_conf].numpy()
        high_conf = high_conf.cpu().numpy()
        classif = [cls for cls, mask in zip(classif, high_conf) if mask]

        # Prepare output data
        output_data = {
            'full_image': None,
            'individual_predictions': [],
        }

        # Process full image with all predictions
        full_image = pred_image.copy()
        for i, (box, label, class_result) in enumerate(zip(boxes, labels, classif)):
            xmin, ymin, xmax, ymax = map(int, box)
            
            # Get the binary mask for this prediction
            mask = masks[i].squeeze()
            mask = (mask > 0.5).astype(np.uint8)
            
            # Calculate lesion features
            features = calculate_lesion_features(mask, image_np, pixel_spacing)
                      

            # Draw on full image
            cv2.rectangle(full_image, (xmin, ymin), (xmax, ymax), (209, 109, 145), 2)
            label_text = f"{class_result} : {CUSTOM_CLASSES[label - 1]} {scores[i]:.2f}"
            cv2.putText(full_image, label_text, (xmin, ymin - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.9, (209, 109, 145), 2)

            colored_mask = np.zeros_like(full_image)
            colored_mask[:, :] = (255, 0, 0)
            full_image = np.where(mask[..., None] > 0, 
                                cv2.addWeighted(full_image, 1, colored_mask, 0.3, 0), 
                                full_image)
            contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            cv2.drawContours(full_image, contours, -1, (0, 255, 255), 2)
            
            ################################################################################
            # Process individual prediction
            single_pred_image = pred_image.copy()            
            cv2.rectangle(single_pred_image, (xmin, ymin), (xmax, ymax), (209, 109, 145), 2)
            cv2.putText(single_pred_image, label_text, (xmin, ymin - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.9, (209, 109, 145), 2)

            single_pred_image = np.where(mask[..., None] > 0, 
                                       cv2.addWeighted(single_pred_image, 1, colored_mask, 0.3, 0), 
                                       single_pred_image)
            cv2.drawContours(single_pred_image, contours, -1, (0, 255, 255), 2)

            # Convert to bytes
            single_pred_image_rgb = cv2.cvtColor(single_pred_image, cv2.COLOR_BGR2RGB)
            _, buffer = cv2.imencode('.png', single_pred_image_rgb)
            image_stream = io.BytesIO(buffer)
            image_stream.seek(0)
            
            output_data['individual_predictions'].append({
                'image': image_stream,
                'features': features # Reuse the coordinates with features
            })

        # Convert full image to bytes
        full_image_rgb = cv2.cvtColor(full_image, cv2.COLOR_BGR2RGB)
        _, buffer = cv2.imencode('.png', full_image_rgb)
        image_stream = io.BytesIO(buffer)
        image_stream.seek(0)
        output_data['full_image'] = image_stream 
        
        # Convert image streams to base64 strings
        def convert_image_to_base64(image_stream: io.BytesIO) -> str:
            image_stream.seek(0)
            return base64.b64encode(image_stream.read()).decode('utf-8')

        # Prepare the response data
        response_data = {
            "full_image": convert_image_to_base64(output_data['full_image']),
            "individual_predictions": [
                {
                    "image": convert_image_to_base64(pred['image']),
                    "features": pred['features']
                }
                for pred in output_data['individual_predictions']
            ],
        }

        return response_data      

    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse(
            status_code=500,
            content={"message": f"Error processing predictions: {str(e)}"}
        )