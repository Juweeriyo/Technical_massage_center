from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, schemas
from database import get_db
from routers.auth import get_current_user
from typing import List

router = APIRouter(prefix="/appointments", tags=["appointments"])

@router.post("/", response_model=schemas.Appointment)
def create_appointment(appointment: schemas.AppointmentCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can create appointments.")
        
    if not appointment.patient_id:
        raise HTTPException(status_code=400, detail="Patient ID is required")
        
    # Validate patient exists
    patient = db.query(models.Patient).filter(models.Patient.id == appointment.patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    db_appointment = models.Appointment(**appointment.model_dump())
    db.add(db_appointment)
    db.commit()
    db.refresh(db_appointment)
    return db_appointment

@router.get("/", response_model=List[schemas.Appointment])
def read_appointments(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    query = db.query(models.Appointment)
    
    if current_user.role == "Doctor":
        query = query.filter(models.Appointment.doctor_id == current_user.id)
        
    appointments = query.order_by(models.Appointment.id.desc()).offset(skip).limit(limit).all()
    return appointments

@router.put("/{appointment_id}", response_model=schemas.Appointment)
def update_appointment(appointment_id: int, appointment: schemas.AppointmentCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role == "Staff":
        raise HTTPException(status_code=403, detail="Not authorized. Staff cannot edit appointments.")
        
    db_appointment = db.query(models.Appointment).filter(models.Appointment.id == appointment_id).first()
    if not db_appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
        
    if current_user.role == "Doctor":
        if db_appointment.doctor_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized. You can only update your own appointments.")
        
        # Doctor can only update status (and notes, though notes are not in AppointmentCreate schema yet, but if added later this pattern helps)
        # Assuming the UI only passes back the updated object, we just update status if that's the only allowed change.
        db_appointment.status = appointment.status
    else:
        # Admin can update everything
        for key, value in appointment.model_dump().items():
            setattr(db_appointment, key, value)
        
    db.commit()
    db.refresh(db_appointment)
    return db_appointment

@router.put("/{appointment_id}/cancel")
def cancel_appointment(appointment_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can cancel appointments.")
        
    db_appointment = db.query(models.Appointment).filter(models.Appointment.id == appointment_id).first()
    if not db_appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
        
    db_appointment.status = "Cancelled"
    db.commit()
    return {"ok": True}

@router.delete("/{appointment_id}")
def delete_appointment(appointment_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can delete appointments.")
        
    db_appointment = db.query(models.Appointment).filter(models.Appointment.id == appointment_id).first()
    if not db_appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
        
    db.delete(db_appointment)
    db.commit()
    return {"detail": "Appointment deleted successfully"}
