from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import models, schemas
from database import get_db
from routers.auth import get_current_user
from typing import List

router = APIRouter(prefix="/payments", tags=["payments"])

@router.post("/", response_model=schemas.Payment)
def create_payment(payment: schemas.PaymentCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can create payments.")
    db_payment = models.Payment(**payment.model_dump())
    db.add(db_payment)
    db.commit()
    db.refresh(db_payment)
    return db_payment

@router.get("/")
def read_payments(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role == "Doctor":
        raise HTTPException(status_code=403, detail="Not authorized")
    
    payments = db.query(models.Payment).order_by(models.Payment.id.desc()).offset(skip).limit(limit).all()
    
    if current_user.role == "Staff":
        return [schemas.PaymentStaff.model_validate(p) for p in payments]
    
    return [schemas.Payment.model_validate(p) for p in payments]

@router.put("/{payment_id}", response_model=schemas.Payment)
def update_payment(payment_id: int, payment: schemas.PaymentCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can edit payments.")
    db_payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not db_payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    for key, value in payment.model_dump().items():
        setattr(db_payment, key, value)
    
    db.commit()
    db.refresh(db_payment)
    return db_payment

@router.delete("/{payment_id}")
def delete_payment(payment_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized. Only admins can delete payments.")
    db_payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not db_payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    db.delete(db_payment)
    db.commit()
    return {"detail": "Payment deleted successfully"}

@router.get("/patient/{patient_id}/status", response_model=schemas.PatientPaymentStatus)
def get_patient_payment_status(patient_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role == "Doctor":
        raise HTTPException(status_code=403, detail="Not authorized")
        
    payments = db.query(models.Payment).filter(models.Payment.patient_id == patient_id).all()
    
    if not payments:
        return {"patient_id": patient_id, "status": "Not Paid"}
        
    total_amount = sum(p.total_amount for p in payments)
    amount_paid = sum(p.amount_paid for p in payments)
    
    if total_amount == 0 and amount_paid == 0:
        status = "Not Paid"
    elif amount_paid >= total_amount:
        status = "All Paid"
    elif amount_paid > 0:
        status = "Partially Paid"
    else:
        status = "Not Paid"
        
    return {"patient_id": patient_id, "status": status}
