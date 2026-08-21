import uuid

from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import DateTime
from sqlalchemy import Boolean
from sqlalchemy.sql import func

from app.database.database import Base


class User(Base):

    __tablename__ = "users"

    id = Column(
        String,
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )

    full_name = Column(
        String,
        nullable=False
    )

    mobile = Column(
        String,
        unique=True,
        nullable=False,
        index=True
    )

    email = Column(
        String,
        unique=True,
        nullable=True,
        index=True
    )

    password_hash = Column(
        String,
        nullable=False
    )

    mpin_hash = Column(
        String,
        nullable=True
    )

    # Account status
    is_active = Column(
        Boolean,
        default=True
    )

    # Mobile/Email/KYC verification
    is_verified = Column(
        Boolean,
        default=False
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )