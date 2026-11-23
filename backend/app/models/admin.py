import uuid
import enum
from sqlalchemy import Column, String, Boolean, DateTime, Enum
from sqlalchemy.sql import func
from app.database.database import Base

class AdminRole(str, enum.Enum):
    SUPER_ADMIN = "SUPER_ADMIN"
    SECURITY_OFFICER = "SECURITY_OFFICER"
    OPERATIONS_OFFICER = "OPERATIONS_OFFICER"

class Admin(Base):
    __tablename__ = "admins"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    role = Column(Enum(AdminRole), default=AdminRole.OPERATIONS_OFFICER, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
