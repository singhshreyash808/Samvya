from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime

class TransactionCreate(BaseModel):
    sender_account_id: str
    recipient_name: str
    recipient_account_number: str
    recipient_bank: Optional[str] = None
    amount: float = Field(..., gt=0)
    description: Optional[str] = None

class TransactionResponse(BaseModel):
    id: str
    sender_account_id: str
    recipient_name: str
    recipient_account_number: str
    recipient_bank: Optional[str]
    amount: float
    description: Optional[str]
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
