from pydantic import BaseModel, EmailStr
from typing import Optional

from app.schemas.device_schema import DeviceRegister


class RegisterUser(BaseModel):

    full_name: str

    mobile: str

    email: Optional[EmailStr] = None

    password: str

    device: DeviceRegister


class LoginUser(BaseModel):

    mobile: str

    password: str

    device: DeviceRegister


class UserResponse(BaseModel):

    id: str

    full_name: str

    mobile: str

    email: Optional[str]

    class Config:
        from_attributes = True