from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

from app.database.database import get_db
from app.models.device import Device
from app.models.login_request import LoginRequest
from app.models.user import User
from app.core.security import decode_token

router = APIRouter(
    prefix="/devices",
    tags=["Devices"]
)


# ─── Schema ────────────────────────────────────────────────────────────────────

class PendingDeviceResponse(BaseModel):
    request_id: str
    device_uuid: str
    device_name: str
    brand: str
    model: str
    android_version: str
    app_version: str
    created_at: str

    class Config:
        from_attributes = True


# ─── Helper: get current user from Bearer token ────────────────────────────────

def get_current_user_from_token(
    token: str,
    db: Session
):
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token."
        )
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found."
        )
    return user


# ─── GET /devices/pending ──────────────────────────────────────────────────────
# Called by primary device to see all pending login requests

@router.get("/pending")
def get_pending_devices(
    token: str,
    db: Session = Depends(get_db)
):
    """
    Returns all pending (unapproved, unrejected, unexpired) device login requests
    for the currently logged-in user. Called by the primary device to show
    the Device Approval tab.
    """
    user = get_current_user_from_token(token, db)

    from datetime import datetime, timezone

    # Get all pending login requests for this user
    pending_requests = (
        db.query(LoginRequest, Device)
        .join(Device, LoginRequest.device_id == Device.id)
        .filter(
            LoginRequest.user_id == user.id,
            LoginRequest.approved == False,
            LoginRequest.rejected == False,
            LoginRequest.expires_at > datetime.now(timezone.utc)
        )
        .order_by(LoginRequest.created_at.desc())
        .all()
    )

    result = []
    for req, device in pending_requests:
        result.append({
            "request_id": req.request_id,
            "device_uuid": device.device_uuid,
            "device_name": device.device_name,
            "brand": device.brand,
            "model": device.model,
            "android_version": device.android_version,
            "app_version": device.app_version,
            "created_at": str(req.created_at),
        })

    return {
        "success": True,
        "count": len(result),
        "pending": result
    }


# ─── GET /devices/all ──────────────────────────────────────────────────────────
# Returns all devices registered to this user

@router.get("/all")
def get_all_devices(
    token: str,
    db: Session = Depends(get_db)
):
    """
    Returns all devices (approved, pending, blocked) linked to the current user.
    """
    user = get_current_user_from_token(token, db)

    devices = db.query(Device).filter(
        Device.user_id == user.id
    ).order_by(Device.created_at.desc()).all()

    result = []
    for d in devices:
        result.append({
            "device_uuid": d.device_uuid,
            "device_name": d.device_name,
            "brand": d.brand,
            "model": d.model,
            "android_version": d.android_version,
            "app_version": d.app_version,
            "is_primary": d.is_primary,
            "approved": d.approved,
            "is_blocked": d.is_blocked,
            "last_login": str(d.last_login) if d.last_login else None,
            "created_at": str(d.created_at),
        })

    return {
        "success": True,
        "count": len(result),
        "devices": result
    }
