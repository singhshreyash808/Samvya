import uuid
from sqlalchemy import Column, String, DateTime, Text
from sqlalchemy.sql import func
from app.database.database import Base

class SecurityEvent(Base):
    __tablename__ = "security_events"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, nullable=True)
    event_type = Column(String, nullable=False) # e.g. "Failed Login", "New Device", "Suspicious Location", "Auth Failure"
    severity = Column(String, default="WARNING") # INFO, WARNING, CRITICAL
    description = Column(Text, nullable=False)
    ip_address = Column(String, nullable=True)
    device_info = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
