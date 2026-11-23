
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.database.database import Base, engine

# Import all models before creating database tables
from app import models

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


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        with engine.begin() as connection:
            connection.execute(text("SELECT 1"))
            Base.metadata.create_all(bind=connection)
    except SQLAlchemyError as exc:
        raise RuntimeError(
            "Database connection or schema initialization failed. "
            "Check DATABASE_URL and confirm the database is reachable."
        ) from exc
    yield


app = FastAPI(
    title="Samvya API",
    description="Rural Banking Platform - Samvya Backend & Admin Portal API",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth_router)
app.include_router(device_router)
app.include_router(assistant_router)
app.include_router(schemes_router)
app.include_router(recommendations_router)
app.include_router(scheme_assistant_router)
app.include_router(bank_accounts_router)
app.include_router(transactions_router)
app.include_router(admin_router)


@app.get("/")
def home():
    return {
        "message": "Samvya Backend & Admin Portal API Running",
        "status": "healthy",
        "version": "1.0.0"
    }


@app.get("/health")
def health_check():
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected"}
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=503,
            detail="Database is unavailable."
        ) from exc
