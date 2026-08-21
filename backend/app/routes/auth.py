from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.core.security import decode_token
from app.models.user import User

from app.services.auth_service import AuthService

from app.schemas.auth_schema import (
    RegisterRequest,
    LoginRequest,
    ApproveDeviceRequest,
    RejectDeviceRequest,
    CheckDeviceStatusRequest,
)


def _get_user_from_token(token: str, db: Session):
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid or expired token.")
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found.")
    return user


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register")
def register_user(
    user: RegisterRequest,
    db: Session = Depends(get_db)
):
    return AuthService.register(
        user,
        db,
    )


@router.post("/login")
def login_user(
    user: LoginRequest,
    db: Session = Depends(get_db)
):
    return AuthService.login(
        user,
        db,
    )


@router.post("/approve-device")
def approve_device(
    request: ApproveDeviceRequest,
    token: str,
    db: Session = Depends(get_db)
):
    user = _get_user_from_token(token, db)
    return AuthService.approve_device(
        request,
        db,
        authorizing_user_id=user.id
    )


@router.post("/reject-device")
def reject_device(
    request: RejectDeviceRequest,
    token: str,
    db: Session = Depends(get_db)
):
    user = _get_user_from_token(token, db)
    return AuthService.reject_device(
        request,
        db,
        authorizing_user_id=user.id
    )


@router.post("/check-device-status")
def check_device_status(
    request: CheckDeviceStatusRequest,
    db: Session = Depends(get_db)
):
    return AuthService.check_device_status(
        request,
        db
    )