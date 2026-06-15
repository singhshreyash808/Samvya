from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.models.user import User
from app.schemas.user_schema import RegisterUser
from app.core.security import hash_password

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register")
def register_user(
    user: RegisterUser,
    db: Session = Depends(get_db)
):

    existing_mobile = db.query(User).filter(
        User.mobile == user.mobile
    ).first()

    if existing_mobile:
        raise HTTPException(
            status_code=400,
            detail="Mobile number already registered."
        )

    if user.email:
        existing_email = db.query(User).filter(
            User.email == user.email
        ).first()

        if existing_email:
            raise HTTPException(
                status_code=400,
                detail="Email already registered."
            )

    new_user = User(
        full_name=user.full_name,
        mobile=user.mobile,
        email=user.email,
        password_hash=hash_password(user.password)
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "Registration Successful",
        "user_id": new_user.id
    }