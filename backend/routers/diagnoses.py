from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models, schemas
from database import get_db
from routers.auth import get_current_user

router = APIRouter(prefix="/diagnoses", tags=["diagnoses"])

@router.post("/", response_model=schemas.Diagnosis)
def create_diagnosis(diagnosis: schemas.DiagnosisCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_diagnosis = models.Diagnosis(**diagnosis.model_dump())
    db.add(db_diagnosis)
    db.commit()
    db.refresh(db_diagnosis)
    return db_diagnosis

@router.get("/", response_model=List[schemas.Diagnosis])
def read_diagnoses(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    diagnoses = db.query(models.Diagnosis).offset(skip).limit(limit).all()
    return diagnoses

@router.get("/patient/{patient_id}", response_model=List[schemas.Diagnosis])
def get_diagnoses_by_patient(patient_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    diagnoses = db.query(models.Diagnosis).filter(models.Diagnosis.patient_id == patient_id).all()
    return diagnoses

@router.post("/session-notes/", response_model=schemas.SessionNote)
def create_session_note(session_note: schemas.SessionNoteCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_note = models.SessionNote(**session_note.model_dump())
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

@router.get("/session-notes/treatment/{treatment_plan_id}", response_model=List[schemas.SessionNote])
def get_session_notes_by_treatment(treatment_plan_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    notes = db.query(models.SessionNote).filter(models.SessionNote.treatment_plan_id == treatment_plan_id).all()
    return notes
