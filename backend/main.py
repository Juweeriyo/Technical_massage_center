# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routers import auth, patients, appointments, treatments, payments, users

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="CERAGEM SOMALIA API")

# Configure CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router)
app.include_router(patients.router)
app.include_router(appointments.router)
app.include_router(treatments.router)
app.include_router(payments.router)
app.include_router(users.router)


@app.get("/")
def read_root():
    return {"message": "Welcome to CERAGEM SOMALIA API"}
