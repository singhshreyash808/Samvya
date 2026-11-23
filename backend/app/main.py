from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.database import Base, engine

# Import ALL models so SQLAlchemy creates their tables in PostgreSQL
from app.models import (
    User, UserProfile, Device, LoginRequest, BankAccount, Transaction,
    SchemeCategory, GovernmentScheme, SchemeEligibilityRules, UserBookmark,
    Admin, Complaint, ComplaintComment, ServiceRequest, RiskEvent, SecurityEvent, AuditLog
)

# Import routers
from app.routes.auth import router as auth_router
from app.api.device import router as device_router
from app.routes.assistant import router as assistant_router
from app.routes.schemes import router as schemes_router
from app.routes.recommendations import router as recommendations_router
from app.routes.scheme_assistant import router as scheme_assistant_router
from app.routes.bank_accounts import router as bank_accounts_router
from app.routes.transactions import router as transactions_router
from app.routes.admin import router as admin_router

# Create all tables in PostgreSQL
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Samvya API",
    description="Rural Banking Platform — Samvya Backend & Admin Portal API",
    version="1.0.0"
)

# ─── CORS ──────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth_router)
app.include_router(device_router)
app.include_router(assistant_router)
app.include_router(schemes_router)
app.include_router(recommendations_router)
app.include_router(scheme_assistant_router)
app.include_router(bank_accounts_router)
app.include_router(transactions_router)
app.include_router(admin_router)

# ─── Health Check ──────────────────────────────────────────────────────────────
@app.get("/")
def home():
    return {
        "message": "Samvya Backend & Admin Portal API Running 🚀",
        "status": "healthy",
        "version": "1.0.0"
    }

@app.get("/health")
def health_check():
    return {"status": "ok"}