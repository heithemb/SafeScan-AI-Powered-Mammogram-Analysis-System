#uvicorn main:app --reload
import base64
import io
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
from dicom_utils import dicom_to_png
from model_utils import load_model, predict
from image_processing import process_predictions
from classifier_utils import load_classifier , classify

app = FastAPI()
model = load_model()  # Initialize model on startup
classifer= load_classifier()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins from the list
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods like GET, POST, PUT, DELETE
    allow_headers=["*"],  # Allows all headers
)
ALLOWED_EXTENSIONS = {".dcm", ".png", ".jpg", ".jpeg"}  # Define allowed file types
def convert_image_to_base64(image_stream: io.BytesIO) -> str:
            image_stream.seek(0)
            return base64.b64encode(image_stream.read()).decode('utf-8')

@app.post("/predict")
async def predict_api(file: UploadFile = File(...)):
    # Extract file extension and validate
    max_size = 10 * 1024 * 1024  # 10 MB
    file_size = len(await file.read())  # Read file to check size
    if file_size > max_size:
        raise HTTPException(status_code=400, detail="File is too large.")
    
    # Reset file pointer for later saving
    await file.seek(0)  # Go back to the start of the file
    
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type: {file_ext}. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
        )

    temp_dir = "temp"
    os.makedirs(temp_dir, exist_ok=True)
    
    temp_input = f"{temp_dir}/{uuid.uuid4()}{file_ext}"
    temp_output = f"{temp_dir}/{uuid.uuid4()}.png"
    
    try:
        # Save file (only reaches here if extension is valid)
        with open(temp_input, "wb") as f:
            # Use async file write with `file.read` to handle the content correctly
            content = await file.read()
            f.write(content)
            original_image_stream = io.BytesIO(content)  # Save stream for base64

        
        # Processing logic
        if file_ext == ".dcm":
            dicom_to_png(temp_input, temp_output)
            image_path = temp_output
        else:
            image_path = temp_input

        results = predict(image_path, model)
        if len(results['boxes'])>0:
            print(results['boxes'])
            print(results['labels'])
            print(results['scores'])
            #classify(image_path,results,classifer)
            results = classify(image_path,results,classifer)
            # Process image and return the result
            response_data = process_predictions(image_path, results)
            return JSONResponse(content=response_data)
    
        return{
                "status": "success",
                "detections": False,
                "full_image": convert_image_to_base64(original_image_stream),
            }        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    finally:
        # Cleanup - remove temporary files
        if os.path.exists(temp_input):
            os.remove(temp_input)
        if os.path.exists(temp_output):
            os.remove(temp_output)
