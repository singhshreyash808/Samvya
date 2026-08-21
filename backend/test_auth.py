import traceback
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database.database import Base, get_db
from app.models.user import User
from app.models.device import Device
from app.models.login_request import LoginRequestModel
from app.schemas.auth_schema import LoginRequest, DeviceSchema
from app.services.auth_service import AuthService
from app.core.security import hash_password

engine = create_engine("sqlite:///./test_db.sqlite", connect_args={"check_same_thread": False})
Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

try:
    # 1. Create User
    new_user = User(
        full_name="Test User",
        mobile="1234567890",
        password_hash=hash_password("password")
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 2. Login with New Device
    device_data = DeviceSchema(
        device_uuid="uuid-1234",
        device_name="Test Phone",
        brand="BrandX",
        model="ModelY",
        android_version="12",
        app_version="1.0",
        fcm_token="token123"
    )
    
    login_req = LoginRequest(
        mobile="1234567890",
        password="password",
        device=device_data
    )

    print("Attempting login...")
    response = AuthService.login(login_req, db)
    print("Login Response:", response)

except Exception as e:
    print("Error occurred!")
    traceback.print_exc()

