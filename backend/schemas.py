# pyrefly: ignore [missing-import] 
from pydantic import BaseModel
from typing import Optional, List
from datetime import date, datetime

# Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# User Schemas
class UserBase(BaseModel):
    username: str
    role: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int

    class Config:
        from_attributes = True

# Patient Schemas
class PatientBase(BaseModel):
    full_name: str
    phone_number: str
    gender: str
    age: int
    address: str
    medical_notes: Optional[str] = None

class PatientCreate(PatientBase):
    pass

class Patient(PatientBase):
    id: int
    patient_number: str
    registration_date: datetime

    class Config:
        from_attributes = True

# Appointment Schemas
class AppointmentBase(BaseModel):
    patient_id: Optional[int] = None
    doctor_id: Optional[int] = None
    date: date
    time: str
    status: str = "Scheduled"

class AppointmentCreate(AppointmentBase):
    pass

class Appointment(AppointmentBase):
    id: int

    class Config:
        from_attributes = True

# TreatmentPlan Schemas
class TreatmentPlanBase(BaseModel):
    patient_id: int
    treatment_name: str
    number_of_sessions: int
    start_date: date
    end_date: Optional[date] = None
    status: str = "Active"

class TreatmentPlanCreate(BaseModel):
    patient_id: int
    doctor_id: int
    treatment_name: str
    mode: int
    number_of_sessions: int
    start_date: date
    status: str

class TreatmentPlan(BaseModel):
    id: int
    patient_id: int
    doctor_id: Optional[int] = None
    treatment_name: str
    mode: Optional[int] = None
    number_of_sessions: int
    start_date: date
    end_date: Optional[date] = None
    status: str

    class Config:
        from_attributes = True    

# Payment Schemas
class PaymentBase(BaseModel):
    patient_id: int
    total_amount: float
    amount_paid: float
    payment_method: str
    status: str = "Unpaid"

class PaymentCreate(PaymentBase):
    pass

class Payment(PaymentBase):
    id: int
    date: datetime

    class Config:
        from_attributes = True

class PaymentStaff(BaseModel):
    id: int
    patient_id: int
    payment_method: str
    status: str
    date: datetime

    class Config:
        from_attributes = True

class PatientPaymentStatus(BaseModel):
    patient_id: int
    status: str

# SessionNote Schemas
class SessionNoteBase(BaseModel):
    treatment_plan_id: int
    doctor_id: int
    date: date
    patient_response: str
    pain_level: int
    notes: str
    next_recommendation: Optional[str] = None

class SessionNoteCreate(SessionNoteBase):
    pass

class SessionNote(SessionNoteBase):
    id: int

    class Config:
        from_attributes = True
