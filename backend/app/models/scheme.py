import uuid
from sqlalchemy import Column, String, Text, Boolean, Integer, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database.database import Base

class SchemeCategory(Base):
    __tablename__ = "scheme_categories"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False, unique=True)
    description = Column(Text, nullable=True)
    icon_url = Column(String, nullable=True)
    
    schemes = relationship("GovernmentScheme", back_populates="category")


class GovernmentScheme(Base):
    __tablename__ = "government_schemes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    ministry = Column(String, nullable=False)
    category_id = Column(String, ForeignKey("scheme_categories.id"))
    
    description = Column(Text, nullable=False)
    benefits = Column(Text, nullable=True)
    application_process = Column(Text, nullable=True)
    required_documents_text = Column(Text, nullable=True)
    official_website = Column(String, nullable=True)
    helpline = Column(String, nullable=True)
    faq_text = Column(Text, nullable=True)
    
    state_availability = Column(String, nullable=True) # E.g. "All", "Uttar Pradesh, Bihar"
    
    is_active = Column(Boolean, default=True)
    last_updated_date = Column(DateTime(timezone=True), server_default=func.now())
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    category = relationship("SchemeCategory", back_populates="schemes")
    eligibility_rules = relationship("SchemeEligibilityRules", back_populates="scheme", uselist=False)
    bookmarks = relationship("UserBookmark", back_populates="scheme")


class SchemeEligibilityRules(Base):
    __tablename__ = "scheme_eligibility_rules"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    scheme_id = Column(String, ForeignKey("government_schemes.id", ondelete="CASCADE"), unique=True)
    
    # Numeric Rules
    min_age = Column(Integer, nullable=True)
    max_age = Column(Integer, nullable=True)
    max_income = Column(Float, nullable=True)
    
    # Categorical Rules (comma separated or specific)
    gender = Column(String, nullable=True) # 'Male', 'Female', 'All'
    allowed_states = Column(String, nullable=True)
    required_occupations = Column(String, nullable=True)
    
    # Boolean Requirements
    requires_farmer = Column(Boolean, default=False)
    requires_student = Column(Boolean, default=False)
    requires_senior_citizen = Column(Boolean, default=False)
    requires_business_owner = Column(Boolean, default=False)
    requires_disability = Column(Boolean, default=False)
    requires_jan_dhan = Column(Boolean, default=False)
    requires_aadhaar = Column(Boolean, default=False)
    requires_land = Column(Boolean, default=False)
    
    scheme = relationship("GovernmentScheme", back_populates="eligibility_rules")


class UserBookmark(Base):
    __tablename__ = "user_bookmarks"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"))
    scheme_id = Column(String, ForeignKey("government_schemes.id", ondelete="CASCADE"))
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    scheme = relationship("GovernmentScheme", back_populates="bookmarks")
