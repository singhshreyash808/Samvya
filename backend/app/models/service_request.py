import uuid
import enum
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum, Text
from sqlalchemy.sql import func
from app.database.database import Base

class ServiceRequestStatus(str, enum.Enum):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"

class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    category = Column(String, nullable=False) # e.g., "Account Limits", "Profile Update", "KYC Verification"
    description = Column(Text, nullable=False)
    status = Column(Enum(ServiceRequestStatus), default=ServiceRequestStatus.PENDING, nullable=False)
    assigned_officer_id = Column(String, ForeignKey("admins.id", ondelete="SET NULL"), nullable=True)
    resolution = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
