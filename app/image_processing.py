import base64
from fastapi.responses import JSONResponse
import numpy as np
import cv2
from PIL import Image
import torch
import io

CUSTOM_CLASSES = ['calc', 'mass']
COLOR = [(209, 109, 145),(0, 255, 255)]  # BGR color for boxes,mask and text
CONTOUR_COLOR = [(0, 255, 255),(209, 109, 145)]  # BGR yellow for contours

from skimage import morphology, measure, feature
from skimage.measure import regionprops, perimeter_crofton

def calculate_lesion_features(mask, image, pixel_spacing=(0.1, 0.1), min_area_px=10):
    from skimage.color import rgb2gray

    # If image has 3 channels, convert to grayscale
    if image.ndim == 3 and image.shape[2] == 3:
        image = rgb2gray(image)
    if image.ndim == 3 and image.shape[2] == 3:
        mask = rgb2gray(mask)
    # 1) Clean & label mask
    bin_mask = morphology.remove_small_objects(mask.astype(bool), min_size=min_area_px)
    labeled = measure.label(bin_mask)
    regions = measure.regionprops(labeled, intensity_image=image)

    # 2) Find the largest valid region
    regions = [r for r in regions if r.area >= min_area_px]
    if not regions:
        return None
    region = max(regions, key=lambda r: r.area)
    
    
    # 3) Morphology (real-world units)
    area_mm2 = region.area * (pixel_spacing[0] * pixel_spacing[1])
    
    
    perimeter_px = perimeter_crofton(region.image, directions=2)  # From skimage.measure
    
    
    perim_mm = perimeter_px * np.mean(pixel_spacing)
    print ('here')
    circularity = (4 * np.pi * area_mm2) / (perim_mm ** 2) if perim_mm > 0 else 0.0
    print ('here')
    eccentricity = region.eccentricity
    print ('here')
    # 4) Intensity
    mean_intensity = region.mean_intensity
    print ('here')
    std_intensity = region.intensity_std  # Use region's intensity_std property
    print ('here')

    # 5) Texture: GLCM homogeneity
    minr, minc, maxr, maxc = region.bbox
    patch = image[minr:maxr, minc:maxc]
    mask_patch = region.image  # Use the region's image as the mask
    print ('here')
    homogeneity = np.nan
    if patch.size >= 4:  # At least 2x2 pixels for GLCM
        # Normalize image to 0-255 if necessary (assuming original is 8-bit)
        # If image is not 8-bit, adjust the bins accordingly
        patch_normalized = (patch - patch.min()) / (patch.max() - patch.min() + 1e-7) * 255
        patch_normalized = patch_normalized.astype(np.uint8)
        
        bins = np.linspace(0, 256, 17)
        quant = np.digitize(patch_normalized, bins) - 1
        quant = np.where(mask_patch, quant, 16).astype(np.uint8)

        glcm = feature.graycomatrix(
            quant,
            distances=[1],
            angles=[0, np.pi/4, np.pi/2, 3*np.pi/4],
            levels=17,
            symmetric=True,
            normed=True
        )
        glcm_lesion = glcm[:16, :16, :, :]
        if glcm_lesion.size and np.any(glcm_lesion):
            homogeneity = float(np.mean(feature.graycoprops(glcm_lesion, 'homogeneity')))
        else:
            homogeneity = np.nan

    # 6) Return a single dictionary
    return {
        'morphology': {
            'area_mm2': area_mm2,
            'perimeter_mm': perim_mm,
            'circularity': circularity,
            'eccentricity': eccentricity
        },
        'intensity': {
            'mean': mean_intensity,
            'std_dev': std_intensity
        },
        'texture': {
            'glcm_homogeneity': homogeneity
        }
    }

def process_predictions(image_path: str, predictions: dict, confidence_threshold=0.5, pixel_spacing=(0.1,0.1)):
    try:
        # Load and convert image
        with Image.open(image_path) as img:
            image_np = np.array(img.convert("RGB"))
        
        if image_np.max() <= 1:
            image_np = (image_np * 255).astype(np.uint8)

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

        output_data = {'full_image': None, 'individual_predictions': []}
        full_image = image_np.copy()
        image_height, image_width = image_np.shape[:2]
        colored_mask = np.zeros_like(image_np)
        

        for i, (box, label, cls_result) in enumerate(zip(boxes, labels, classif)):
            xmin, ymin, xmax, ymax = map(int, box)
            mask = (masks[i].squeeze() > 0.5).astype(np.uint8)
            print(CUSTOM_CLASSES[label-1])
            if CUSTOM_CLASSES[label-1]=='mass':
                color_tbm=COLOR[0]
                color_c=CONTOUR_COLOR[0]
            else:
                color_tbm=COLOR[1]
                color_c=CONTOUR_COLOR[1]
            colored_mask[:] = color_tbm
            # Calculate text position
            label_text = f"{cls_result} : {CUSTOM_CLASSES[label-1]} {scores[i]:.2f}"
            font = cv2.FONT_HERSHEY_DUPLEX
            font_scale = 1.2
            thickness = 2
            (text_w, text_h), baseline = cv2.getTextSize(
                label_text, font, font_scale, thickness
            )
            
            # Horizontal positioning
            box_center = (xmin + xmax) // 2
            text_x = max(0, min(box_center - text_w//2, image_width - text_w))
            
            # Vertical positioning
            text_y = ymin - 10  # Try above box
            if text_y - text_h < 0:  # Not enough space above
                text_y = ymax + text_h + 10  # Place below box
                if text_y + baseline > image_height:
                    text_y = ymin + (ymax - ymin)//2  # Center vertically in box

            # Draw on full image
            cv2.rectangle(full_image, (xmin, ymin), (xmax, ymax), color_tbm, 2)
            cv2.putText(full_image, label_text, (text_x, text_y),
                       font, font_scale, color_tbm, thickness)
            
            # Add mask overlay
            full_image = np.where(mask[..., None], 
                                cv2.addWeighted(full_image, 1, colored_mask, 0.3, 0),
                                full_image)
            
            # Draw contours
            contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            cv2.drawContours(full_image, contours, -1, color_c, 2)

            # Process individual prediction
            single_pred = image_np.copy()
            cv2.rectangle(single_pred, (xmin, ymin), (xmax, ymax), color_tbm, 2)
            cv2.putText(single_pred, label_text, (text_x, text_y),
                       font, font_scale, color_tbm, thickness)
            single_pred = np.where(mask[..., None], 
                                 cv2.addWeighted(single_pred, 1, colored_mask, 0.3, 0),
                                 single_pred)
            cv2.drawContours(single_pred, contours, -1, color_c, 2)

            # Encode individual image
            _, buffer = cv2.imencode('.jpg', cv2.cvtColor(single_pred, cv2.COLOR_RGB2BGR))
            output_data['individual_predictions'].append({
                'image': base64.b64encode(buffer).decode('utf-8'),
                'features': calculate_lesion_features(mask, image_np, pixel_spacing)
            })

        # Encode full image
        _, buffer = cv2.imencode('.jpg', cv2.cvtColor(full_image, cv2.COLOR_RGB2BGR))
        output_data['full_image'] = base64.b64encode(buffer).decode('utf-8')

        return {
            "full_image": output_data['full_image'],
            "individual_predictions": output_data['individual_predictions']
        }

    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse(
            status_code=500,
            content={"message": f"Processing error: {str(e)}"}
        )