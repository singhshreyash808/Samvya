import uuid
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Enum
from sqlalchemy.sql import func
from app.database.database import Base
import enum

class TransactionStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    sender_account_id = Column(String, ForeignKey("bank_accounts.id", ondelete="CASCADE"), nullable=False)
    recipient_name = Column(String, nullable=False)
    recipient_account_number = Column(String, nullable=False)
    recipient_bank = Column(String, nullable=True)
    amount = Column(Float, nullable=False)
    description = Column(String, nullable=True)
    status = Column(
        Enum(TransactionStatus),
        default=TransactionStatus.pending,
        nullable=False
    )
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
