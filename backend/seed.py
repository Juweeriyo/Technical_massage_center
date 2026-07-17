import sys
import os

# Add the current directory to sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal, engine, Base
from core.security import get_password_hash
import models

def seed_db():
    print("Creating tables...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    
    # Check if admin already exists
    admin = db.query(models.User).filter(models.User.username == "admin").first()
    if not admin:
        print("Creating admin user...")
        admin_user = models.User(
            username="admin",
            hashed_password=get_password_hash("admin123"),
            role="Admin"
        )
        db.add(admin_user)
        
    # Check if doctor already exists
    doctor = db.query(models.User).filter(models.User.username == "doctor").first()
    if not doctor:
        print("Creating doctor user...")
        doctor_user = models.User(
            username="doctor",
            hashed_password=get_password_hash("doctor123"),
            role="Doctor"
        )
        db.add(doctor_user)
        
    # Check if staff already exists
    staff = db.query(models.User).filter(models.User.username == "staff").first()
    if not staff:
        print("Creating staff user...")
        staff_user = models.User(
            username="staff",
            hashed_password=get_password_hash("staff123"),
            role="Staff"
        )
        db.add(staff_user)

    db.commit()
    db.close()
    print("Seeding complete.")

if __name__ == "__main__":
    seed_db()
