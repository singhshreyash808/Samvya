import uuid
import enum
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum, Text
from sqlalchemy.sql import func
from app.database.database import Base

class RiskLevel(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class RiskEvent(Base):
    __tablename__ = "risk_events"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    transaction_id = Column(String, nullable=True)
    user_id = Column(String, nullable=True)
    risk_level = Column(Enum(RiskLevel), default=RiskLevel.LOW, nullable=False)
    risk_score = Column(Float, default=0.0, nullable=False)
    reason = Column(Text, nullable=False)
    status = Column(String, default="FLAGGED") # FLAGGED, INVESTIGATING, DISMISSED, RESOLVED
    created_at = Column(DateTime(timezone=True), server_default=func.now())
