# SafeScan: AI-Powered Mammogram Analysis System
This repository is part of a research project aimed at enhancing the detection of masses and calcifications in mammography. It contains the most effective combination of models and tools developed during the project.

# What’s Inside
 Detection & Segmentation: 
Code for training and running a Mask R-CNN model to detect and segment breast abnormalities.

 Classification: 
An SVM model that classifies the segmented regions (e.g., benign or malignant).

 Mobile User Interface: 
A Flutter application called SafeScan, which allows radiologists to:

Upload mammography images in DICOM, PNG, JPG, or JPEG formats

View the AI analysis results (detection, segmentation, classification)

Automatically generate a conclusion using Qwen2.5 VL-32B Instruct via OpenRouter API

Download detailed medical reports

Access other integrated features for improved diagnostic assistance

# Dataset & Model Training
Mask R-CNN was trained using the Chinese Mammography Database (CMMD).

The SVM classifier was trained using a combination of CMMD and CBIS-DDSM datasets.

Dataset links (via Roboflow and TCIA) are provided in the training scripts.

To access the models send a request via this link: https://drive.google.com/drive/folders/1zvw5nNOgdjQJEa5JWGL5O-J2lhX2ylf_?usp=sharing
# Setup Instructions
To run the project, you must configure two environment files:

.env for the backend (API, inference, and logic)

.env for the frontend (Flutter app configuration)

# Note
This system is intended as a research prototype and is not approved for clinical use.

# Authors
This project was developed as an end-of-study research project by:
Noor MEZNI and Heithem BENMOUSSA

# Contact
mezniinoor@gmail.com & Heithem.benmoussa.71@gmail.com
