from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
import models, schemas
from database import get_db
from routers.auth import get_current_user
from typing import List

router = APIRouter(prefix="/patients", tags=["patients"])

def generate_patient_number(db: Session):
    last_patient = db.query(models.Patient).order_by(models.Patient.id.desc()).first()
    if last_patient:
        last_number = int(last_patient.patient_number.split("-")[1])
        new_number = last_number + 1
    else:
        new_number = 1
    return f"CER-{new_number:06d}"

@router.post("/", response_model=schemas.Patient)
def create_patient(patient: schemas.PatientCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    patient_number = generate_patient_number(db)
    db_patient = models.Patient(**patient.model_dump(), patient_number=patient_number)
    db.add(db_patient)
    db.commit()
    db.refresh(db_patient)
    return db_patient

@router.get("/", response_model=List[schemas.Patient])
def read_patients(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    patients = db.query(models.Patient).offset(skip).limit(limit).all()
    return patients

@router.get("/search", response_model=List[schemas.Patient])
def search_patients(query: str = Query(..., description="Search by Phone Number or Patient ID"), db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Global search on phone number OR patient number
    patients = db.query(models.Patient).filter(
        or_(
            models.Patient.phone_number.ilike(f"%{query}%"),
            models.Patient.patient_number.ilike(f"%{query}%")
        )
    ).all()
    return patients

@router.get("/{patient_id}", response_model=schemas.Patient)
def read_patient(patient_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if db_patient is None:
        raise HTTPException(status_code=404, detail="Patient not found")
    return db_patient

@router.put("/{patient_id}", response_model=schemas.Patient)
def update_patient(patient_id: int, patient: schemas.PatientCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if db_patient is None:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    for key, value in patient.model_dump().items():
        setattr(db_patient, key, value)
        
    db.commit()
    db.refresh(db_patient)
    return db_patient

@router.delete("/{patient_id}")
def delete_patient(patient_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if db_patient is None:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    db.delete(db_patient)
    db.commit()
    return {"ok": True}
