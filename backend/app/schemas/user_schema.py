from pydantic import BaseModel
from typing import Optional


class RegisterUser(BaseModel):

    full_name: str

    mobile: str

    email: Optional[str] = None

    password: str


class UserResponse(BaseModel):

    id: str

    full_name: str

    mobile: str

    email: Optional[str]

    class Config:
        from_attributes = True