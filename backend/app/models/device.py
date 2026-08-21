import uuid

from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import Boolean
from sqlalchemy import DateTime
from sqlalchemy import ForeignKey
from sqlalchemy.sql import func

from app.database.database import Base


class Device(Base):

    __tablename__ = "devices"

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

    # Flutter device identifier
    device_uuid = Column(
        String,
        nullable=False,
        index=True
    )

    device_name = Column(
        String,
        nullable=False
    )

    brand = Column(
        String,
        nullable=False
    )

    model = Column(
        String,
        nullable=False
    )

    android_version = Column(
        String,
        nullable=False
    )

    app_version = Column(
        String,
        nullable=False
    )

    # Firebase Push Token
    fcm_token = Column(
        String,
        nullable=True
    )

    # Main trusted device
    is_primary = Column(
        Boolean,
        default=False
    )

    # Approved by user?
    approved = Column(
        Boolean,
        default=False
    )

    # Device blocked by user
    is_blocked = Column(
        Boolean,
        default=False
    )

    # Optional device nickname
    nickname = Column(
        String,
        nullable=True
    )

    # IP address
    ip_address = Column(
        String,
        nullable=True
    )

    # City / State
    location = Column(
        String,
        nullable=True
    )

    # Login timestamp
    last_login = Column(
        DateTime(timezone=True),
        nullable=True
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