# pyrefly: ignore [missing-import]
from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime, Text, ForeignKey, Numeric
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import relationship
# pyrefly: ignore [missing-import]
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False) # Admin, Doctor, Staff

class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)
    patient_number = Column(String, unique=True, index=True, nullable=False) # e.g. CER-000123
    full_name = Column(String, nullable=False)
    phone_number = Column(String, index=True, nullable=False)
    gender = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    address = Column(String, nullable=False)
    medical_notes = Column(Text, nullable=True)
    registration_date = Column(DateTime(timezone=True), server_default=func.now())

    appointments = relationship("Appointment", back_populates="patient", cascade="all, delete")
    treatment_plans = relationship("TreatmentPlan", back_populates="patient", cascade="all, delete")
    payments = relationship("Payment", back_populates="patient", cascade="all, delete")

class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"))
    doctor_id = Column(Integer, ForeignKey("users.id"))
    date = Column(Date, nullable=False)
    time = Column(String, nullable=False)
    status = Column(String, nullable=False, default="Scheduled") # Scheduled, Completed, Cancelled

    patient = relationship("Patient", back_populates="appointments")
    doctor = relationship("User")


class TreatmentPlan(Base):
    __tablename__ = "treatment_plans"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"))
    doctor_id = Column(Integer, ForeignKey("users.id"))
    treatment_name = Column(String, nullable=False)
    mode = Column(Integer)
    number_of_sessions = Column(Integer, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    status = Column(String, nullable=False, default="Active") # Active, Completed

    patient = relationship("Patient", back_populates="treatment_plans")
    session_notes = relationship("SessionNote", back_populates="treatment_plan", cascade="all, delete")
class SessionNote(Base):
    __tablename__ = "session_notes"

    id = Column(Integer, primary_key=True, index=True)
    treatment_plan_id = Column(Integer, ForeignKey("treatment_plans.id"))
    doctor_id = Column(Integer, ForeignKey("users.id"))
    date = Column(Date, nullable=False)
    patient_response = Column(Text, nullable=False)
    pain_level = Column(Integer, nullable=False) # 1-10
    notes = Column(Text, nullable=False)
    next_recommendation = Column(Text, nullable=True)
    
    treatment_plan = relationship("TreatmentPlan", back_populates="session_notes")

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"))
    total_amount = Column(Numeric(10, 2), nullable=False)
    amount_paid = Column(Numeric(10, 2), nullable=False, default=0.0)
    payment_method = Column(String, nullable=False) # Cash, Mobile Money
    status = Column(String, nullable=False, default="Unpaid") # Paid, Partial, Unpaid
    date = Column(DateTime(timezone=True), server_default=func.now())

    patient = relationship("Patient", back_populates="payments")
