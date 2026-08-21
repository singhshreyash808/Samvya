from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# --- Category Schemas ---

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None

class CategoryResponse(CategoryBase):
    id: str

    class Config:
        from_attributes = True

# --- Scheme Schemas ---

class SchemeBase(BaseModel):
    name: str
    ministry: str
    description: str
    benefits: Optional[str] = None
    application_process: Optional[str] = None
    required_documents_text: Optional[str] = None
    official_website: Optional[str] = None
    helpline: Optional[str] = None
    faq_text: Optional[str] = None
    state_availability: Optional[str] = None

class SchemeCreate(SchemeBase):
    category_id: str

class SchemeResponse(SchemeBase):
    id: str
    category_id: str
    is_active: bool
    last_updated_date: datetime
    
    # These fields can be populated dynamically
    is_eligible: Optional[bool] = None
    match_score: Optional[float] = None
    category: Optional[CategoryResponse] = None

    class Config:
        from_attributes = True

# --- Eligibility Rules Schema ---

class EligibilityRulesBase(BaseModel):
    min_age: Optional[int] = None
    max_age: Optional[int] = None
    max_income: Optional[float] = None
    gender: Optional[str] = None
    allowed_states: Optional[str] = None
    required_occupations: Optional[str] = None
    
    requires_farmer: bool = False
    requires_student: bool = False
    requires_senior_citizen: bool = False
    requires_business_owner: bool = False
    requires_disability: bool = False
    requires_jan_dhan: bool = False
    requires_aadhaar: bool = False
    requires_land: bool = False

class SchemeEligibilityRulesResponse(EligibilityRulesBase):
    id: str
    scheme_id: str

    class Config:
        from_attributes = True

# --- Combined Detail Schema ---

class SchemeDetailResponse(SchemeResponse):
    eligibility_rules: Optional[SchemeEligibilityRulesResponse] = None
