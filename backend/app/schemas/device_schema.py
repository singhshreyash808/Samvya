from pydantic import BaseModel
from typing import Optional


class DeviceRegister(BaseModel):

    device_uuid: str

    device_name: str

    brand: str

    model: str

    android_version: str

    app_version: str

    fcm_token: Optional[str] = None


class DeviceResponse(BaseModel):

    id: str

    user_id: str

    device_uuid: str

    device_name: str

    brand: str

    model: str

    android_version: str

    app_version: str

    approved: bool

    is_primary: bool

    class Config:
        from_attributes = True