from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, schemas
from database import get_db
from routers.auth import get_current_user
from typing import List

router = APIRouter(prefix="/treatments", tags=["treatments"])

@router.post("/plans", response_model=schemas.TreatmentPlan)
def create_treatment_plan(plan: schemas.TreatmentPlanCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role not in ["Admin", "Doctor"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_plan = models.TreatmentPlan(**plan.model_dump())
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan

@router.get("/plans", response_model=List[schemas.TreatmentPlan])
def read_treatment_plans(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    plans = db.query(models.TreatmentPlan).offset(skip).limit(limit).all()
    return plans

@router.post("/diagnoses", response_model=schemas.Diagnosis)
def create_diagnosis(diagnosis: schemas.DiagnosisCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role not in ["Admin", "Doctor"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_diagnosis = models.Diagnosis(**diagnosis.model_dump())
    db.add(db_diagnosis)
    db.commit()
    db.refresh(db_diagnosis)
    return db_diagnosis
