from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class BankAccountBase(BaseModel):
    bank_name: str
    account_number: str
    ifsc_code: str
    account_holder_name: str
    phone_number: str

class BankAccountCreate(BankAccountBase):
    tpin: str = Field(..., min_length=4, max_length=6, description="Transaction PIN")

class BankAccountResponse(BankAccountBase):
    id: str
    user_id: str
    balance: float
    created_at: datetime
    
    # We purposefully do NOT return the tpin or tpin_hash

    class Config:
        from_attributes = True

class VerifyTpinRequest(BaseModel):
    tpin: str
