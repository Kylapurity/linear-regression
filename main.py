# Import required libraries
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import pickle
import numpy as np

# Create FastAPI app
app = FastAPI(
    title="Student Grade Prediction",   # API description
)

# Allow all origins to access our API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"], 
)

# Load our trained model
try:
    MODEL_PATH = "model.pkl"
    model = pickle.load(open(MODEL_PATH, 'rb'))
except Exception as e:
    print(f"Error loading model: {e}")

# Define what data we need for prediction
class StudentData(BaseModel):
    # Number of times student was absent
    Absences: int = Field(
        ..., 
        ge=0,  # Must be 0 or more
        le=30, # Must be 30 or less
        description="Number of times absent from class (0-30)"
    )
    
    # Whether student has parent support
    ParentalSupport: int = Field(
        ..., 
        ge=0, 
        le=1,
        description="Does student have parent support? (0: No, 1: Yes)"
    )
    
    # Hours spent studying per week
    StudyTimeWeekly: float = Field(
        ..., 
        ge=0.0,
        le=168.0,
        description="Hours spent studying per week"
    )
    
    # Whether student gets tutoring
    Tutoring: int = Field(
        ..., 
        ge=0,
        le=1,
        description="Does student receive tutoring? (0: No, 1: Yes)"
    )

    # Example values to show users
    class Config:
        schema_extra = {
            "example": {
                "Absences": 5,
                "ParentalSupport": 1,
                "StudyTimeWeekly": 15.5,
                "Tutoring": 1
            }
        }

# API endpoint for predictions
@app.post("/predict")
async def predict_grade(student: StudentData):
    try:
        # Get student data in correct order for model
        features = np.array([[
            student.Absences,
            student.ParentalSupport,
            student.StudyTimeWeekly,
            student.Tutoring
        ]])
        
        # Make prediction
        prediction = model.predict(features)[0]
        
        # Return prediction and input data
        return {
            "predicted_grade": float(prediction),
            "student_data": student.dict()
        }
    
    except Exception as e:
        # If something goes wrong, return error
        raise HTTPException(
            status_code=500,
            detail=f"Error making prediction: {str(e)}"
        )
# Welcome message at homepage
@app.get("/")
async def home():
    return {
        "message": "Welcome to the Student Grade Prediction API!",
    }
# Run the API
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)