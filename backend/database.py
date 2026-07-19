# pyrefly: ignore [missing-import]
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base
# pyrefly: ignore [missing-import]
from sqlalchemy.orm import sessionmaker
import os

# PostgreSQL Connection String (adjust as needed for local environment)
# Using a default local connection string, change if needed.
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:1234@localhost:5434/ceragem_db")

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
