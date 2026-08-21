import uuid

from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import Boolean
from sqlalchemy import DateTime
from sqlalchemy import Float
from sqlalchemy import ForeignKey
from sqlalchemy.sql import func

from app.database.database import Base


class LoginRequest(Base):

    __tablename__ = "login_requests"

    id = Column(
        String,
        primary_key=True,
        default=lambda: str(uuid.uuid4())
    )

    user_id = Column(
        String,
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )

    device_id = Column(
        String,
        ForeignKey("devices.id"),
        nullable=False,
        index=True
    )

    request_id = Column(
        String,
        unique=True,
        nullable=False,
        default=lambda: str(uuid.uuid4())
    )

    approved = Column(
        Boolean,
        default=False
    )

    rejected = Column(
        Boolean,
        default=False
    )

    expires_at = Column(
        DateTime(timezone=True),
        nullable=False
    )

    approved_at = Column(
        DateTime(timezone=True),
        nullable=True
    )

    # Location at time of login request
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )