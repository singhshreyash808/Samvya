from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.database.database import Base

class UserProfile(Base):
    __tablename__ = "user_profiles"

    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)  # 'Male', 'Female', 'Other'
    state = Column(String, nullable=True)
    district = Column(String, nullable=True)
    occupation = Column(String, nullable=True)
    annual_income = Column(Float, default=0.0)
    
    # Eligibility boolean flags
    is_farmer = Column(Boolean, default=False)
    is_student = Column(Boolean, default=False)
    is_senior_citizen = Column(Boolean, default=False)
    is_business_owner = Column(Boolean, default=False)
    has_disability = Column(Boolean, default=False)
    has_bank_account = Column(Boolean, default=False)
    is_aadhaar_linked = Column(Boolean, default=False)
    has_jan_dhan = Column(Boolean, default=False)
    owns_land = Column(Boolean, default=False)
    
    education_level = Column(String, nullable=True)  # e.g., '10th', '12th', 'Graduate'
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
