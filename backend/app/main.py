from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.database import Base, engine

# Import ALL models so SQLAlchemy creates their tables in NeonDB
from app.models.user import User
from app.models.device import Device
from app.models.login_request import LoginRequest
from app.models.bank_account import BankAccount  # Ensures table creation
from app.models.transaction import Transaction     # Ensures table creation

# Import routers
from app.routes.auth import router as auth_router
from app.api.device import router as device_router
from app.routes.assistant import router as assistant_router
from app.routes.schemes import router as schemes_router
from app.routes.recommendations import router as recommendations_router
from app.routes.scheme_assistant import router as scheme_assistant_router
from app.routes.bank_accounts import router as bank_accounts_router
from app.routes.transactions import router as transactions_router

# Create all tables in NeonDB (safe — never drops existing data)
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Samvya API",
    description="Rural Banking Platform — Samvya Backend",
    version="1.0.0"
)

# ─── CORS ──────────────────────────────────────────────────────────────────────
# Allows Flutter app (any origin) to call this backend
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


# ─── Health Check ──────────────────────────────────────────────────────────────
@app.get("/")
def home():
    return {
        "message": "Samvya Backend Running 🚀",
        "status": "healthy",
        "version": "1.0.0"
    }


@app.get("/health")
def health_check():
    return {"status": "ok"}