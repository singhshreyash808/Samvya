from typing import Optional

from pydantic import BaseModel, EmailStr, Field


# ---------------- Device ---------------- #

class DeviceSchema(BaseModel):
    device_uuid: str = Field(..., min_length=5)
    device_name: str
    brand: str
    model: str
    android_version: str
    app_version: str
    fcm_token: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


# ---------------- Register ---------------- #

class RegisterRequest(BaseModel):
    full_name: str = Field(..., min_length=3, max_length=100)
    mobile: str = Field(..., min_length=10, max_length=15)
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=8)
    device: DeviceSchema


# ---------------- Login ---------------- #

class LoginRequest(BaseModel):
    mobile: str = Field(..., min_length=10, max_length=15)
    password: str
    device: DeviceSchema


# ---------------- Device Approval ---------------- #

class ApproveDeviceRequest(BaseModel):
    device_uuid: str


class RejectDeviceRequest(BaseModel):
    device_uuid: str


class CheckDeviceStatusRequest(BaseModel):
    request_id: str


# ---------------- Responses ---------------- #

class RegisterResponse(BaseModel):
    success: bool
    message: str
    user_id: str


class LoginResponse(BaseModel):
    success: bool
    message: str
    device_status: str
    token: Optional[str] = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class CheckDeviceStatusResponse(BaseModel):
    success: bool
    approved: bool
    rejected: bool
    expired: bool
    token: Optional[str] = None
    full_name: Optional[str] = None
    mobile: Optional[str] = None
    email: Optional[str] = None