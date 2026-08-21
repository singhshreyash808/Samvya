from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List

from app.database.database import get_db
from app.core.security import decode_token
from app.models.user import User
from app.models.bank_account import BankAccount
from app.models.transaction import Transaction, TransactionStatus
from app.schemas.transaction_schema import TransactionCreate, TransactionResponse


def _get_user_from_token(token: str, db: Session) -> User:
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid or expired token.")
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    return user


router = APIRouter(prefix="/transactions", tags=["Transactions"])


@router.post("", response_model=TransactionResponse)
def create_transaction(
    data: TransactionCreate,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Create a new pending transaction from a user's bank account."""
    user = _get_user_from_token(token, db)

    # Verify the sender account belongs to this user
    account = db.query(BankAccount).filter(
        BankAccount.id == data.sender_account_id,
        BankAccount.user_id == user.id
    ).first()
    if not account:
        raise HTTPException(status_code=403, detail="Account not found or access denied.")

    txn = Transaction(
        sender_account_id=data.sender_account_id,
        recipient_name=data.recipient_name,
        recipient_account_number=data.recipient_account_number,
        recipient_bank=data.recipient_bank,
        amount=data.amount,
        description=data.description,
        status=TransactionStatus.pending,
    )
    db.add(txn)
    db.commit()
    db.refresh(txn)
    return txn


@router.get("", response_model=List[TransactionResponse])
def get_my_transactions(
    status: str = Query(None, description="Filter: pending | approved | rejected | all"),
    account_id: str = Query(None, description="Filter by a specific bank account ID"),
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Get all transactions across all user accounts."""
    user = _get_user_from_token(token, db)

    # Get all account IDs belonging to the user
    user_account_ids = [
        a.id for a in db.query(BankAccount.id).filter(BankAccount.user_id == user.id).all()
    ]
    
    # If account_id is provided, ensure it belongs to the user
    if account_id:
        if account_id not in user_account_ids:
            raise HTTPException(status_code=403, detail="Account not found or access denied.")
        query = db.query(Transaction).filter(Transaction.sender_account_id == account_id)
    else:
        query = db.query(Transaction).filter(Transaction.sender_account_id.in_(user_account_ids))

    if status and status != "all":
        try:
            status_enum = TransactionStatus(status)
            query = query.filter(Transaction.status == status_enum)
        except ValueError:
            raise HTTPException(status_code=400, detail=f"Invalid status: {status}")

    transactions = query.order_by(Transaction.created_at.desc()).all()
    return transactions


@router.patch("/{txn_id}/approve", response_model=TransactionResponse)
def approve_transaction(
    txn_id: str,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Approve a pending transaction."""
    user = _get_user_from_token(token, db)
    txn = _get_user_transaction(txn_id, user.id, db)

    if txn.status != TransactionStatus.pending:
        raise HTTPException(status_code=400, detail="Only pending transactions can be approved.")

    txn.status = TransactionStatus.approved
    db.commit()
    db.refresh(txn)
    return txn


@router.patch("/{txn_id}/reject", response_model=TransactionResponse)
def reject_transaction(
    txn_id: str,
    token: str = Query(...),
    db: Session = Depends(get_db)
):
    """Reject a pending transaction."""
    user = _get_user_from_token(token, db)
    txn = _get_user_transaction(txn_id, user.id, db)

    if txn.status != TransactionStatus.pending:
        raise HTTPException(status_code=400, detail="Only pending transactions can be rejected.")

    txn.status = TransactionStatus.rejected
    db.commit()
    db.refresh(txn)
    return txn


def _get_user_transaction(txn_id: str, user_id: str, db: Session) -> Transaction:
    """Helper to validate a transaction belongs to the requesting user."""
    account_ids = [
        a.id for a in db.query(BankAccount.id).filter(BankAccount.user_id == user_id).all()
    ]
    txn = db.query(Transaction).filter(
        Transaction.id == txn_id,
        Transaction.sender_account_id.in_(account_ids)
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found.")
    return txn
