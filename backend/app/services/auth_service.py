import uuid
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func

from app.models.user import User
from app.models.device import Device
from app.models.login_request import LoginRequest
from app.services.notification_service import NotificationService
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
)


class AuthService:

    @staticmethod
    def register(user, db: Session):
        # --- Pre-checks (before touching DB) ---
        mobile_exists = db.query(User).filter(
            User.mobile == user.mobile
        ).first()

        if mobile_exists:
            raise HTTPException(
                status_code=400,
                detail="Mobile number is already registered."
            )

        if user.email:
            email_exists = db.query(User).filter(
                User.email == user.email
            ).first()

            if email_exists:
                raise HTTPException(
                    status_code=400,
                    detail="Email address is already registered."
                )

        try:
            new_user = User(
                full_name=user.full_name,
                mobile=user.mobile,
                email=user.email if user.email else None,
                password_hash=hash_password(user.password)
            )

            db.add(new_user)
            db.flush()       # Assigns ID without committing
            db.refresh(new_user)  # Ensure new_user.id is populated

            primary_device = Device(
                user_id=new_user.id,
                device_uuid=user.device.device_uuid,
                device_name=user.device.device_name,
                brand=user.device.brand,
                model=user.device.model,
                android_version=user.device.android_version,
                app_version=user.device.app_version,
                fcm_token=user.device.fcm_token,
                approved=True,
                is_primary=True,
                last_login=datetime.now(timezone.utc)
            )

            db.add(primary_device)
            db.commit()
            db.refresh(new_user)

            token = create_access_token(
                user_id=new_user.id,
                mobile=new_user.mobile
            )

            return {
                "success": True,
                "message": "Registration Successful",
                "user_id": new_user.id,
                "token": token
            }

        except IntegrityError as e:
            db.rollback()
            # Handle race-condition duplicate key at DB level
            error_msg = str(e.orig).lower()
            if "mobile" in error_msg:
                raise HTTPException(
                    status_code=400,
                    detail="Mobile number is already registered."
                )
            elif "email" in error_msg:
                raise HTTPException(
                    status_code=400,
                    detail="Email address is already registered."
                )
            else:
                raise HTTPException(
                    status_code=400,
                    detail="Registration failed due to a conflict. Please try again."
                )

        except Exception as e:
            db.rollback()
            raise HTTPException(
                status_code=500,
                detail=f"Registration failed: {str(e)}"
            )

    @staticmethod
    def login(user, db: Session):
        try:
            existing_user = db.query(User).filter(
                User.mobile == user.mobile
            ).first()

            if existing_user is None:
                raise HTTPException(
                    status_code=404,
                    detail="User not found"
                )

            if not verify_password(user.password, existing_user.password_hash):
                raise HTTPException(
                    status_code=401,
                    detail="Invalid password"
                )

            device = db.query(Device).filter(
                Device.user_id == existing_user.id,
                Device.device_uuid == user.device.device_uuid
            ).first()

            # Case 1: Existing Device Found
            if device:
                if device.is_blocked:
                    raise HTTPException(
                        status_code=403,
                        detail="This device has been blocked."
                    )

                # PRIMARY DEVICE: Always auto-approve. If user reinstalled the app,
                # their primary device should never be locked out.
                if device.is_primary and not device.approved:
                    device.approved = True
                    device.fcm_token = user.device.fcm_token
                    device.last_login = datetime.now(timezone.utc)
                    db.commit()

                if not device.approved:
                    # Find existing pending login request (use DB func.now() for reliable timezone comparison)
                    login_request = db.query(LoginRequest).filter(
                        LoginRequest.device_id == device.id,
                        LoginRequest.approved == False,
                        LoginRequest.rejected == False,
                        LoginRequest.expires_at > func.now()
                    ).order_by(LoginRequest.created_at.desc()).first()

                    req_id = login_request.request_id if login_request else None

                    # If the previous request expired or doesn't exist, create a new one
                    if not login_request:
                        req_id = str(uuid.uuid4())
                        new_login_request = LoginRequest(
                            request_id=req_id,
                            user_id=existing_user.id,
                            device_id=device.id,
                            approved=False,
                            rejected=False,
                            expires_at=datetime.now(timezone.utc) + timedelta(minutes=10),
                            latitude=user.device.latitude,
                            longitude=user.device.longitude
                        )
                        db.add(new_login_request)
                        db.commit()

                    return {
                        "success": False,
                        "message": "Your device is waiting for approval.",
                        "device_status": "pending",
                        "request_id": req_id
                    }

                # Update latest device information
                device.device_name = user.device.device_name
                device.brand = user.device.brand
                device.model = user.device.model
                device.android_version = user.device.android_version
                device.app_version = user.device.app_version
                device.fcm_token = user.device.fcm_token
                device.last_login = datetime.now(timezone.utc)

                db.commit()

                token = create_access_token(
                    user_id=existing_user.id,
                    mobile=existing_user.mobile
                )

                return {
                    "success": True,
                    "message": "Login Successful",
                    "token": token,
                    "device_status": "approved",
                    "full_name": existing_user.full_name,
                    "mobile": existing_user.mobile,
                    "email": existing_user.email or "",
                    "is_primary": device.is_primary
                }

            # Case 2: Completely new device UUID not seen before.
            # Check if the user already has at least one approved/primary device.
            # If not (e.g. they deleted all devices from DB), auto-approve as primary.
            has_approved_device = db.query(Device).filter(
                Device.user_id == existing_user.id,
                Device.approved == True,
                Device.is_blocked == False
            ).first()

            if not has_approved_device:
                # No active approved device exists — treat this as a primary device re-registration
                new_primary = Device(
                    user_id=existing_user.id,
                    device_uuid=user.device.device_uuid,
                    device_name=user.device.device_name,
                    brand=user.device.brand,
                    model=user.device.model,
                    android_version=user.device.android_version,
                    app_version=user.device.app_version,
                    fcm_token=user.device.fcm_token,
                    approved=True,
                    is_primary=True,
                    last_login=datetime.now(timezone.utc)
                )
                db.add(new_primary)
                db.commit()

                token = create_access_token(
                    user_id=existing_user.id,
                    mobile=existing_user.mobile
                )

                return {
                    "success": True,
                    "message": "Login Successful",
                    "token": token,
                    "device_status": "approved",
                    "full_name": existing_user.full_name,
                    "mobile": existing_user.mobile,
                    "email": existing_user.email or "",
                    "is_primary": True
                }

            # Case 3: Genuinely new secondary device — send for approval
            new_device = Device(
                user_id=existing_user.id,
                device_uuid=user.device.device_uuid,
                device_name=user.device.device_name,
                brand=user.device.brand,
                model=user.device.model,
                android_version=user.device.android_version,
                app_version=user.device.app_version,
                fcm_token=user.device.fcm_token,
                approved=False,
                is_primary=False
            )
            db.add(new_device)
            db.commit()
            db.refresh(new_device)

            # Create a login approval request for the admin/primary device
            request_id = str(uuid.uuid4())
            new_login_request = LoginRequest(
                request_id=request_id,
                user_id=existing_user.id,
                device_id=new_device.id,
                approved=False,
                rejected=False,
                expires_at=datetime.now(timezone.utc) + timedelta(minutes=10),
                latitude=user.device.latitude,
                longitude=user.device.longitude
            )
            db.add(new_login_request)
            db.commit()

            # Send push notification to primary device
            NotificationService.send_new_login_request(db, existing_user, new_device)

            return {
                "success": False,
                "message": "New device detected. Verification request sent.",
                "device_status": "pending",
                "request_id": request_id
            }

        except HTTPException:
            raise  # Re-raise HTTP exceptions (404, 401, 403) as-is
        except Exception as e:
            db.rollback()
            print(f"[AuthService.login] Unexpected error: {e}")
            raise HTTPException(
                status_code=500,
                detail=f"Login failed due to a server error. Please try again."
            )


    @staticmethod
    def approve_device(request, db: Session, authorizing_user_id: str = None):
        query = db.query(Device).filter(Device.device_uuid == request.device_uuid)
        
        if authorizing_user_id:
            query = query.filter(Device.user_id == authorizing_user_id)
            
        device = query.first()

        if device is None:
            raise HTTPException(
                status_code=404,
                detail="Device not found or you are not authorized to approve it."
            )

        device.approved = True
        device.is_blocked = False
        device.last_login = datetime.now(timezone.utc)

        login_request = db.query(LoginRequest).filter(
            LoginRequest.device_id == device.id,
            LoginRequest.approved == False,
            LoginRequest.rejected == False
        ).order_by(
            LoginRequest.created_at.desc()
        ).first()

        if login_request:
            login_request.approved = True
            login_request.approved_at = datetime.now(timezone.utc)

        db.commit()

        return {
            "success": True,
            "message": "Device approved successfully."
        }

    @staticmethod
    def reject_device(request, db: Session, authorizing_user_id: str = None):
        query = db.query(Device).filter(Device.device_uuid == request.device_uuid)
        
        if authorizing_user_id:
            query = query.filter(Device.user_id == authorizing_user_id)
            
        device = query.first()

        if device is None:
            raise HTTPException(
                status_code=404,
                detail="Device not found or you are not authorized to reject it."
            )

        device.approved = False
        device.is_blocked = True

        # Also mark the login request as rejected if it exists
        login_request = db.query(LoginRequest).filter(
            LoginRequest.device_id == device.id,
            LoginRequest.approved == False,
            LoginRequest.rejected == False
        ).order_by(
            LoginRequest.created_at.desc()
        ).first()

        if login_request:
            login_request.rejected = True

        db.commit()

        return {
            "success": True,
            "message": "Device rejected."
        }

    @staticmethod
    def check_device_status(request, db: Session):
        login_request = db.query(LoginRequest).filter(
            LoginRequest.request_id == request.request_id
        ).first()

        if login_request is None:
            raise HTTPException(
                status_code=404,
                detail="Invalid request."
            )

        if login_request.rejected:
            return {
                "success": False,
                "approved": False,
                "rejected": True,
                "expired": False
            }

        if login_request.expires_at < datetime.now(timezone.utc):
            return {
                "success": False,
                "approved": False,
                "rejected": False,
                "expired": True
            }

        if not login_request.approved:
            return {
                "success": True,
                "approved": False,
                "rejected": False,
                "expired": False
            }

        user = db.query(User).filter(
            User.id == login_request.user_id
        ).first()

        token = create_access_token(
            user_id=user.id,
            mobile=user.mobile
        )

        return {
            "success": True,
            "approved": True,
            "rejected": False,
            "expired": False,
            "token": token,
            "full_name": user.full_name,
            "mobile": user.mobile,
            "email": user.email or ""
        }