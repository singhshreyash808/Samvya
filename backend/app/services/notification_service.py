from sqlalchemy.orm import Session

from app.models.device import Device

# Firebase Admin is optional — backend works without it
# If you have a service account JSON, initialize firebase_admin
# before importing this service
try:
    from firebase_admin import messaging
    _firebase_available = True
except ImportError:
    _firebase_available = False


class NotificationService:

    @staticmethod
    def send_new_login_request(
        db: Session,
        user,
        new_device
    ):
        # Skip if Firebase is not available
        if not _firebase_available:
            print("[NotificationService] firebase_admin not available — skipping push notification.")
            return False

        primary_device = db.query(Device).filter(
            Device.user_id == user.id,
            Device.is_primary == True,
            Device.approved == True
        ).first()

        if not primary_device:
            return False

        if not primary_device.fcm_token:
            return False

        try:
            message = messaging.Message(
                token=primary_device.fcm_token,
                notification=messaging.Notification(
                    title="Samvya Security",
                    body=f"New login request from {new_device.device_name}"
                ),
                data={
                    "type": "login_request",
                    "user_id": str(user.id),
                    "device_uuid": str(new_device.device_uuid),
                    "device_name": str(new_device.device_name),
                    "brand": str(new_device.brand),
                    "model": str(new_device.model)
                }
            )
            messaging.send(message)
            return True

        except Exception as e:
            print(f"[NotificationService] Failed to send push notification: {e}")
            return False