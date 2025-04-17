import numpy as np
import joblib
from PIL import Image
import cv2
import os
from sklearn.preprocessing import StandardScaler
from keras.applications.densenet import DenseNet121, preprocess_input as dpi
from keras.applications.convnext import ConvNeXtTiny, preprocess_input as cpi
import matplotlib.pyplot as plt

def load_classifier():
    print('Loading classifier model...')
    classifier = joblib.load(r"models\svm+lgbmdensenet+convnexttiny+9720+c=6+k=sigmoid+augmentation.pkl")
    return classifier
def smart_crop_from_box(orig_cv, box, target_size=224):
    import cv2
    import numpy as np

    height, width = orig_cv.shape[:2]
    x1, y1, x2, y2 = map(int, box)
    box_center_x = (x1 + x2) // 2
    box_center_y = (y1 + y2) // 2

    crop_sizes = [112, 224, 512, 750, 1024,1500]

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

def extract_deep_features(image_rgb):
    # Read grayscale image
    if image_rgb.ndim == 3:
        image_rgb = np.expand_dims(image_rgb, axis=0)

    # DenseNet feature extraction
    model_densenet = DenseNet121(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    img_preprocessed_dense = dpi(image_rgb)
    features_dense = model_densenet.predict(img_preprocessed_dense)

    # ConvNeXt feature extraction
    model_convnext = ConvNeXtTiny(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    img_preprocessed_conv = cpi(image_rgb)
    features_conv = model_convnext.predict(img_preprocessed_conv)

    # Reshape and combine features
    flat_dense = features_dense.reshape(features_dense.shape[0], -1)
    flat_conv = features_conv.reshape(features_conv.shape[0], -1)
    combined_features = np.hstack([flat_dense, flat_conv])
    return combined_features


def classify(image_path, results, classifier):
    try:
        orig_cv = cv2.imread(image_path)
        orig_height, orig_width = orig_cv.shape[:2]

        # Resize image to 957x1147
        target_width = 957
        target_height = 1147
        resized_cv = cv2.resize(orig_cv, (target_width, target_height))
        
        # Calculate scale factors
        scale_x = target_width / orig_width
        scale_y = target_height / orig_height

        # Optional: convert BGR to RGB if needed later
        resized_rgb = cv2.cvtColor(resized_cv, cv2.COLOR_BGR2RGB)

        boxes = results['boxes']
        scores = results['scores']
        results['classification']=[]
        for i in range(len(boxes)):
            if scores[i] < 0.5:
                continue
            
            box = boxes[i] # in case it's a tensor
            # Scale the bounding box
            x1, y1, x2, y2 = box
            x1 = int(x1 * scale_x)
            x2 = int(x2 * scale_x)
            y1 = int(y1 * scale_y)
            y2 = int(y2 * scale_y)
            scaled_box = [x1, y1, x2, y2]

            cropped_img = smart_crop_from_box(resized_rgb, scaled_box, target_size=224)
            
            # Convert BGR (OpenCV) to RGB for matplotlib
            cropped_rgb = cv2.cvtColor(cropped_img, cv2.COLOR_BGR2RGB)
            X = extract_deep_features(cropped_rgb)
            scaler = joblib.load(r"models\scaler.joblib")
            X=scaler.transform(X)
            y = classifier.predict(X)[0]
            print(y)
            if y==0:
                results['classification'].append('Begnin')
            elif y==1:
                results['classification'].append('Malignant')
            """
            plt.figure(figsize=(4, 4))
            plt.imshow(cropped_rgb)
            plt.title(f"Cropped Region {i+1}")
            plt.axis('off')
            plt.show()"""
        return results
    except Exception as e:
        print(f"Error: {e}")
        raise



    

    
    
    
    
    
    
    
    
    
    
    