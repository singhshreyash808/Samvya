from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class UserProfileBase(BaseModel):
    age: Optional[int] = None
    gender: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None
    occupation: Optional[str] = None
    annual_income: float = 0.0
    
    is_farmer: bool = False
    is_student: bool = False
    is_senior_citizen: bool = False
    is_business_owner: bool = False
    has_disability: bool = False
    has_bank_account: bool = False
    is_aadhaar_linked: bool = False
    has_jan_dhan: bool = False
    owns_land: bool = False
    
    education_level: Optional[str] = None

class UserProfileCreate(UserProfileBase):
    pass

class UserProfileUpdate(UserProfileBase):
    pass

class UserProfileResponse(UserProfileBase):
    user_id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
