from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import pickle
import numpy as np
import os

app = FastAPI(
    title="Student Grade Prediction",   
    description="Predict student grades based on various factors"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    MODEL_PATH = "model.pkl"
    model = pickle.load(open(MODEL_PATH, 'rb'))
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

class StudentData(BaseModel):
    Absences: int = Field(
        ..., 
        ge=0,  # Changed Low to ge (greater than or equal)
        le=30, # Changed great to le (less than or equal)
        description="Number of times absent from class (0-30)"
    )
    
    ParentalSupport: int = Field(
        ..., 
        ge=0, 
        le=4,
        description="Does student have parent support? (0: None 1: Low 2: Moderate 3: High 4: Very High)"
    )
    
    StudyTimeWeekly: float = Field(
        ..., 
        ge=0.0,
        le=168.0,
        description="Hours spent studying per week"
    )
    
    Tutoring: int = Field(
        ..., 
        ge=0, 
        le=1,
        description="Does student receive tutoring? (0: No, 1: Yes)"
    )

    class Config:
        schema_extra = {
            "example": {
                "Absences": 5,
                "ParentalSupport": 1,
                "StudyTimeWeekly": 15.5,
                "Tutoring": 1
            }
        }

@app.post("/predict")
async def predict_grade(student: StudentData):
    if model is None:
        raise HTTPException(
            status_code=500,
            detail="Model not loaded"
        )

    try:
        features = np.array([[
            student.Absences,
            student.ParentalSupport,
            student.StudyTimeWeekly,
            student.Tutoring
        ]])
        
        prediction = model.predict(features)[0]
        
        return {
            "GPA": float(prediction),  # Changed from GPA to predicted_grade
            "success": True
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error making prediction: {str(e)}"
        )

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None
    }

@app.get("/")
async def home():
    return {
        "message": "Welcome to the Student Grade Prediction API!",
        "docs_url": "/docs",
        "health_check": "/health"
    }