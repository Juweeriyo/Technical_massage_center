from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import date

import models
import schemas
from database import get_db
from routers.auth import get_current_user

router = APIRouter(prefix="/treatments", tags=["treatments"])

@router.post("/plans", response_model=schemas.TreatmentPlan)
def create_treatment_plan(
    plan: schemas.TreatmentPlanCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role not in ["Admin", "Doctor"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_plan = models.TreatmentPlan(**plan.model_dump())
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan

@router.get("/plans", response_model=List[schemas.TreatmentPlan])
def read_treatment_plans(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    plans = db.query(models.TreatmentPlan).offset(skip).limit(limit).all()
    return plans

@router.put("/plans/{plan_id}", response_model=schemas.TreatmentPlan)
def update_treatment_plan(
    plan_id: int, 
    plan: schemas.TreatmentPlanCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role not in ["Admin", "Doctor"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_plan = db.query(models.TreatmentPlan).filter(models.TreatmentPlan.id == plan_id).first()
    if not db_plan:
        raise HTTPException(status_code=404, detail="Plan not found")
        
    for key, value in plan.model_dump().items():
        setattr(db_plan, key, value)
        
    # Auto-set end_date if status is Completed
    if db_plan.status == "Completed" and not db_plan.end_date:
        db_plan.end_date = date.today()
    elif db_plan.status == "Active":
        db_plan.end_date = None
        
    db.commit()
    db.refresh(db_plan)
    return db_plan

@router.post("/sessions", response_model=schemas.SessionNote)
def create_session_note(
    note: schemas.SessionNoteCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if current_user.role not in ["Admin", "Doctor"]:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_note = models.SessionNote(**note.model_dump())
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

@router.get("/sessions/{plan_id}", response_model=List[schemas.SessionNote])
def read_session_notes(
    plan_id: int, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    notes = db.query(models.SessionNote).filter(models.SessionNote.treatment_plan_id == plan_id).all()
    return notes
