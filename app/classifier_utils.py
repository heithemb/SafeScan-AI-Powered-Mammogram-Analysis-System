import numpy as np
import joblib
from PIL import Image
import cv2
import os
from sklearn.preprocessing import StandardScaler
from keras.applications.densenet import DenseNet121, preprocess_input as dpi
from keras.applications.convnext import ConvNeXtTiny, preprocess_input as cpi
import matplotlib.pyplot as plt
import joblib



def load_classifier():
    print('Loading classifier model...')
    classifier = joblib.load(r"models\svm+lgbmdensenet+convnexttiny+9720+c=6+k=sigmoid+augmentation.pkl")
    return classifier
def smart_crop_from_box(orig_cv, box, target_size=224):
    # (Keep the same implementation as before)


    height, width = orig_cv.shape[:2]
    x1, y1, x2, y2 = map(int, box)
    box_center_x = (x1 + x2) // 2
    box_center_y = (y1 + y2) // 2

    crop_sizes = [112, 224, 512, 750, 1024, 1500]

    for crop_size in crop_sizes:
        crop_x1 = max(0, box_center_x - crop_size // 2)
        crop_y1 = max(0, box_center_y - crop_size // 2)
        crop_x2 = min(width, crop_x1 + crop_size)
        crop_y2 = min(height, crop_y1 + crop_size)

        # Adjust to keep crop size
        if crop_x2 - crop_x1 < crop_size:
            crop_x1 = max(0, crop_x2 - crop_size)
        if crop_y2 - crop_y1 < crop_size:
            crop_y1 = max(0, crop_y2 - crop_size)

        # Check if box fits inside the crop
        if x1 >= crop_x1 and y1 >= crop_y1 and x2 <= crop_x2 and y2 <= crop_y2:
            cropped = orig_cv[crop_y1:crop_y2, crop_x1:crop_x2]
            cropped_resized = cv2.resize(cropped, (target_size, target_size), interpolation=cv2.INTER_LINEAR)
            return cropped_resized

    # Fallback: crop entire image if none fit
    cropped = cv2.resize(orig_cv, (target_size, target_size), interpolation=cv2.INTER_LINEAR)
    return cropped

def extract_deep_features(image_batch, model_densenet, model_convnext):
    """Process batch of images through both models"""
    
    
    # DenseNet preprocessing and features
    img_preprocessed_dense = dpi(image_batch.copy())
    features_dense = model_densenet.predict(img_preprocessed_dense, verbose=0)
    
    # ConvNeXt preprocessing and features
    img_preprocessed_conv = cpi(image_batch.copy())
    features_conv = model_convnext.predict(img_preprocessed_conv, verbose=0)
    
    # Combine features
    flat_dense = features_dense.reshape(features_dense.shape[0], -1)
    flat_conv = features_conv.reshape(features_conv.shape[0], -1)
    return np.hstack([flat_dense, flat_conv])

def classify(image_path, results, classifier):
    try:

        # Load models and scaler ONCE
        model_densenet = DenseNet121(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
        model_convnext = ConvNeXtTiny(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
        scaler = joblib.load(r"models\scaler.joblib")

        orig_cv = cv2.imread(image_path)
        orig_height, orig_width = orig_cv.shape[:2]

        # Resize image to target dimensions
        resized_cv = cv2.resize(orig_cv, (957, 1147))
        scale_x = 957 / orig_width
        scale_y = 1147 / orig_height
        resized_rgb = cv2.cvtColor(resized_cv, cv2.COLOR_BGR2RGB)

        # Batch processing preparation
        cropped_images = []
        boxes = results['boxes']
        scores = results['scores']
        results['classification'] = []

        # Collect valid crops
        for i, (box, score) in enumerate(zip(boxes, scores)):
            if score < 0.5:
                continue
                
            # Scale coordinates
            x1, y1, x2, y2 = (np.array(box) * [scale_x, scale_y, scale_x, scale_y]).astype(int)
            cropped_img = smart_crop_from_box(resized_rgb, (x1, y1, x2, y2))
            cropped_images.append(cropped_img)
            
            """plt.figure(figsize=(4, 4))
            plt.imshow(cropped_img)
            plt.title(f"Cropped Region {i+1}")
            plt.axis('off')
            plt.show()"""
        # Batch process if we have valid detections
        if cropped_images:
            # Convert list to numpy array (batch_size, 224, 224, 3)
            batch_images = np.array(cropped_images)
            
            # Extract features and predict
            features = extract_deep_features(batch_images, model_densenet, model_convnext)
            features_scaled = scaler.transform(features)
            predictions = classifier.predict(features_scaled)

            # Map predictions to labels
            for pred in predictions:
                results['classification'].append('Benign' if pred == 0 else 'Malignant')

        return results
    except Exception as e:
        print(f"Error: {e}")
        raise

    

    
    
    
    
    
    
    
    
    
    
    
