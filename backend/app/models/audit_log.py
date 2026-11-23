import uuid
from sqlalchemy import Column, String, DateTime, Text
from sqlalchemy.sql import func
from app.database.database import Base

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    admin_id = Column(String, nullable=False)
    admin_name = Column(String, nullable=False)
    action = Column(String, nullable=False) # e.g. "VIEW_TRANSACTION", "SUSPEND_USER", "UPDATE_COMPLAINT"
    resource = Column(String, nullable=False) # e.g. "TXN8291", "USER_104"
    result = Column(String, default="SUCCESS") # SUCCESS, FAILED
    details = Column(Text, nullable=True)
    ip_address = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
