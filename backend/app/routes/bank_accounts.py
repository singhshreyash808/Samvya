from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List

from app.database.database import get_db
from app.core.security import decode_token, hash_password, verify_password
from app.models.user import User
from app.models.bank_account import BankAccount
from app.schemas.bank_account_schema import BankAccountCreate, BankAccountResponse, VerifyTpinRequest


def _get_user_from_token(token: str, db: Session) -> User:
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid or expired token.")
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found.")
    return user


router = APIRouter(
    prefix="/accounts",
    tags=["Bank Accounts"]
)


@router.post("", response_model=BankAccountResponse)
def add_bank_account(
    account: BankAccountCreate,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Add a new bank account for the authenticated user."""
    user = _get_user_from_token(token, db)

    # Prevent duplicate account numbers for the same user
    existing = db.query(BankAccount).filter(
        BankAccount.user_id == user.id,
        BankAccount.account_number == account.account_number
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="This account number is already linked to your profile.")

    # Hash the TPIN before storing
    tpin_hashed = hash_password(account.tpin)

    new_account = BankAccount(
        user_id=user.id,
        bank_name=account.bank_name,
        account_number=account.account_number,
        ifsc_code=account.ifsc_code,
        account_holder_name=account.account_holder_name,
        phone_number=account.phone_number,
        tpin_hash=tpin_hashed,
    )

    db.add(new_account)
    db.commit()
    db.refresh(new_account)
    return new_account


@router.get("", response_model=List[BankAccountResponse])
def get_my_accounts(
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Fetch all bank accounts for the authenticated user."""
    user = _get_user_from_token(token, db)
    accounts = db.query(BankAccount).filter(BankAccount.user_id == user.id).all()
    return accounts


@router.post("/{account_id}/verify-tpin")
def verify_tpin(
    account_id: str,
    request: VerifyTpinRequest,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Verify the TPIN for a given account. Returns success or failure."""
    user = _get_user_from_token(token, db)

    account = db.query(BankAccount).filter(
        BankAccount.id == account_id,
        BankAccount.user_id == user.id
    ).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found.")

    is_valid = verify_password(request.tpin, account.tpin_hash)

    if not is_valid:
        raise HTTPException(status_code=401, detail="Incorrect TPIN. Please try again.")

    return {"success": True, "message": "TPIN verified successfully."}


@router.delete("/{account_id}")
def delete_bank_account(
    account_id: str,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Remove a linked bank account."""
    user = _get_user_from_token(token, db)
    account = db.query(BankAccount).filter(
        BankAccount.id == account_id,
        BankAccount.user_id == user.id
    ).first()
    if not account:
        raise HTTPException(status_code=404, detail="Account not found.")
    db.delete(account)
    db.commit()
    return {"success": True, "message": "Account removed."}
