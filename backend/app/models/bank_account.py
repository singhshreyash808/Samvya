import uuid
from sqlalchemy import Column, String, DateTime, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database.database import Base

class BankAccount(Base):
    __tablename__ = "bank_accounts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    bank_name = Column(String, nullable=False)
    account_number = Column(String, nullable=False)
    ifsc_code = Column(String, nullable=False)
    account_holder_name = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    
    # Store hashed TPIN for security
    tpin_hash = Column(String, nullable=False)
    
    # Store account balance
    balance = Column(Float, default=50000.0, nullable=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
