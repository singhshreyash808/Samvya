import uuid
import enum
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum, Text, Boolean
from sqlalchemy.sql import func
from app.database.database import Base

class ComplaintPriority(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class ComplaintStatus(str, enum.Enum):
    OPEN = "OPEN"
    IN_PROGRESS = "IN_PROGRESS"
    RESOLVED = "RESOLVED"
    REJECTED = "REJECTED"

class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    amount = Column(Float, nullable=True)
    priority = Column(Enum(ComplaintPriority), default=ComplaintPriority.MEDIUM, nullable=False)
    status = Column(Enum(ComplaintStatus), default=ComplaintStatus.OPEN, nullable=False)
    assigned_officer_id = Column(String, ForeignKey("admins.id", ondelete="SET NULL"), nullable=True)
    internal_notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class ComplaintComment(Base):
    __tablename__ = "complaint_comments"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    complaint_id = Column(String, ForeignKey("complaints.id", ondelete="CASCADE"), nullable=False)
    author_id = Column(String, nullable=False) # User ID or Admin ID
    author_name = Column(String, nullable=False)
    comment = Column(Text, nullable=False)
    is_internal = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
