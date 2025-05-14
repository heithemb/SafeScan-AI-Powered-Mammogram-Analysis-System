import base64
import io
import os
import uuid
import time
import datetime
import smtplib
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from config import Settings
from dicom_utils import dicom_to_png
from model_utils import load_model, predict
from image_processing import process_predictions
from classifier_utils import load_classifier, classify
from sendmail import send_email, reply_email

# Dependency to load settings from .env

def get_settings() -> Settings:
    return Settings()

# Initialize FastAPI app
app = FastAPI()

# Load models on startup
model = load_model()
classifier = load_classifier()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ALLOWED_EXTENSIONS = {".dcm",".dicom", ".png", ".jpg", ".jpeg"}
MAX_FILE_SIZE = 60 * 1024 * 1024  # 60 MB

def convert_image_to_base64(image_stream: io.BytesIO) -> str:
    image_stream.seek(0)
    return base64.b64encode(image_stream.read()).decode('utf-8')

@app.post("/predict")
async def predict_api(
    file: UploadFile = File(...),
    pixel_spacing: str = Form(None)
):
    print("Received file:", file.filename)

    # Parse pixel_spacing
    try:
        pixel_spacing_value = float(pixel_spacing) if pixel_spacing else None
    except ValueError:
        raise HTTPException(400, "Invalid pixel spacing. Must be a number.")

    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(400, "File is too large.")
    await file.seek(0)

    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(400, f"Unsupported file type: {ext}")

    temp_dir = "temp"
    os.makedirs(temp_dir, exist_ok=True)
    input_path = os.path.join(temp_dir, f"{uuid.uuid4()}{ext}")
    output_path = os.path.join(temp_dir, f"{uuid.uuid4()}.png")

    try:
        with open(input_path, "wb") as f:
            f.write(content)
        original_stream = io.BytesIO(content)

        # Convert DICOM if needed
        if ext in [".dcm", ".dicom"]:
            dicom_to_png(input_path, output_path)
            image_path = output_path
        else:
            image_path = input_path

        results = predict(image_path, model)
        if results['boxes']:
            results = classify(image_path, results, classifier)
            response = process_predictions(image_path, results, pixel_spacing_value)
            return JSONResponse(content=response)

        return {
            "status": "success",
            "detections": False,
            "full_Normal_image": convert_image_to_base64(original_stream)
        }
    except Exception as e:
        raise HTTPException(500, str(e))
    finally:
        for path in (input_path, output_path):
            if os.path.exists(path):
                os.remove(path)

# Email data model
class EmailData(BaseModel):
    name: str
    email: EmailStr
    subject: str
    message: str

@app.post("/send-email")
async def send_email_endpoint(
    email_data: EmailData,
    settings: Settings = Depends(get_settings)
):
    try:
        # Prepare email content
        body_text = (
            f"New Contact Form Submission:\n\n"
            f"Name: {email_data.name}\n"
            f"Email: {email_data.email}\n"
            f"Subject: {email_data.subject}\n"
            f"Message:\n{email_data.message}\n"
        )

        # Send and reply
        send_email(
            subject=email_data.subject,
            email=email_data.email,
            name=email_data.name,
            message=email_data.message,
            body=body_text,
            settings=settings,
            recipient_email=settings.email
        )
        reply_email(
            subject=email_data.subject,
            email=email_data.email,
            name=email_data.name,
            message=email_data.message,
            settings=settings
        )

        return {"status": "success", "message": "Email processed"}
    except Exception as e:
        print(str(e))
        raise HTTPException(500, str(e))
