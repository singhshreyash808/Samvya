from fastapi import APIRouter, Depends, HTTPException, Body, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, date
from typing import Optional, List

from app.database.database import get_db
from app.core.security import hash_password, verify_password, create_access_token, decode_token
from app.models.user import User
from app.models.transaction import Transaction, TransactionStatus
from app.models.admin import Admin, AdminRole
from app.models.complaint import Complaint, ComplaintComment, ComplaintStatus, ComplaintPriority
from app.models.service_request import ServiceRequest, ServiceRequestStatus
from app.models.risk_event import RiskEvent, RiskLevel
from app.models.security_event import SecurityEvent
from app.models.audit_log import AuditLog

router = APIRouter(
    prefix="/admin",
    tags=["Admin Portal"]
)

# Helper function to seed default Super Admin if none exists
def seed_default_admin(db: Session):
    admin_count = db.query(Admin).count()
    if admin_count == 0:
        default_admin = Admin(
            full_name="Super Admin",
            email="admin@samvya.com",
            password_hash=hash_password("admin123"),
            role=AdminRole.SUPER_ADMIN,
            is_active=True
        )
        db.add(default_admin)
        db.commit()

# Helper for logging admin actions
def log_audit(db: Session, admin: Admin, action: str, resource: str, result: str = "SUCCESS", details: str = None):
    audit = AuditLog(
        admin_id=admin.id,
        admin_name=admin.full_name,
        action=action,
        resource=resource,
        result=result,
        details=details
    )
    db.add(audit)
    db.commit()

# Dependency to get current admin from token
def get_current_admin(token: str = Query(..., alias="token"), db: Session = Depends(get_db)) -> Admin:
    payload = decode_token(token)
    if not payload or payload.get("type") != "admin_access":
        raise HTTPException(status_code=401, detail="Invalid or expired admin token")
    admin_id = payload.get("sub")
    admin = db.query(Admin).filter(Admin.id == admin_id, Admin.is_active == True).first()
    if not admin:
        raise HTTPException(status_code=403, detail="Admin not found or inactive")
    return admin


# ─── 1. ADMIN AUTH ──────────────────────────────────────────────────────────────
@router.post("/auth/login")
def admin_login(payload: dict = Body(...), db: Session = Depends(get_db)):
    seed_default_admin(db)
    email = payload.get("email", "").strip()
    password = payload.get("password", "").strip()

    admin = db.query(Admin).filter(Admin.email == email).first()
    if not admin or not verify_password(password, admin.password_hash):
        raise HTTPException(status_code=401, detail="Invalid admin credentials")

    if not admin.is_active:
        raise HTTPException(status_code=403, detail="Admin account is disabled")

    # Create admin specific token
    token = create_access_token(user_id=admin.id, mobile=admin.email)
    # Re-encode payload with admin type
    decoded = decode_token(token)
    decoded["type"] = "admin_access"
    decoded["role"] = admin.role.value

    from jose import jwt
    from app.core.security import SECRET_KEY, ALGORITHM
    admin_token = jwt.encode(decoded, SECRET_KEY, algorithm=ALGORITHM)

    log_audit(db, admin, "ADMIN_LOGIN", f"Admin:{admin.email}", "SUCCESS", "Logged into admin portal")

    return {
        "success": True,
        "token": admin_token,
        "admin": {
            "id": admin.id,
            "full_name": admin.full_name,
            "email": admin.email,
            "role": admin.role.value
        }
    }


# ─── 2. DASHBOARD METRICS ────────────────────────────────────────────────────────
@router.get("/dashboard")
def get_dashboard_metrics(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)

    total_users = db.query(User).count()
    active_users = db.query(User).filter(User.is_active == True).count()
    pending_users = db.query(User).filter(User.is_verified == False).count()

    total_transactions = db.query(Transaction).count()
    successful_txns = db.query(Transaction).filter(Transaction.status == TransactionStatus.approved).count()
    failed_txns = db.query(Transaction).filter(Transaction.status == TransactionStatus.rejected).count()
    pending_txns = db.query(Transaction).filter(Transaction.status == TransactionStatus.pending).count()

    pending_complaints = db.query(Complaint).filter(Complaint.status.in_([ComplaintStatus.OPEN, ComplaintStatus.IN_PROGRESS])).count()
    high_risk_events = db.query(RiskEvent).filter(RiskEvent.risk_level == RiskLevel.HIGH).count()
    security_events_count = db.query(SecurityEvent).count()

    recent_txns = db.query(Transaction).order_by(Transaction.created_at.desc()).limit(5).all()
    recent_security = db.query(SecurityEvent).order_by(SecurityEvent.created_at.desc()).limit(5).all()

    log_audit(db, admin, "VIEW_DASHBOARD", "System Dashboard", "SUCCESS")

    return {
        "success": True,
        "stats": {
            "total_users": total_users,
            "active_users": active_users,
            "pending_users": pending_users,
            "total_transactions": total_transactions,
            "successful_transactions": successful_txns,
            "failed_transactions": failed_txns,
            "pending_transactions": pending_txns,
            "pending_complaints": pending_complaints,
            "high_risk_events": high_risk_events,
            "security_events": security_events_count
        },
        "recent_transactions": [
            {
                "id": t.id,
                "recipient": t.recipient_name,
                "amount": t.amount,
                "status": t.status.value if hasattr(t.status, 'value') else str(t.status),
                "created_at": t.created_at.isoformat() if t.created_at else None
            } for t in recent_txns
        ],
        "recent_security": [
            {
                "id": s.id,
                "event_type": s.event_type,
                "severity": s.severity,
                "description": s.description,
                "created_at": s.created_at.isoformat() if s.created_at else None
            } for s in recent_security
        ]
    }


# ─── 3. USER MANAGEMENT ──────────────────────────────────────────────────────────
@router.get("/users")
def list_users(token: str = Query(...), search: Optional[str] = None, db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    query = db.query(User)
    if search:
        query = query.filter((User.full_name.ilike(f"%{search}%")) | (User.mobile.ilike(f"%{search}%")) | (User.email.ilike(f"%{search}%")))
    users = query.order_by(User.created_at.desc()).all()

    return {
        "success": True,
        "users": [
            {
                "id": u.id,
                "full_name": u.full_name,
                "mobile": u.mobile,
                "email": u.email,
                "is_active": u.is_active,
                "is_verified": u.is_verified,
                "created_at": u.created_at.isoformat() if u.created_at else None
            } for u in users
        ]
    }

@router.get("/users/{user_id}")
def get_user_details(user_id: str, token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    complaints = db.query(Complaint).filter(Complaint.user_id == user_id).all()

    log_audit(db, admin, "VIEW_USER_PROFILE", f"User:{user_id}", "SUCCESS")

    return {
        "success": True,
        "user": {
            "id": user.id,
            "full_name": user.full_name,
            "mobile": user.mobile,
            "email": user.email,
            "is_active": user.is_active,
            "is_verified": user.is_verified,
            "created_at": user.created_at.isoformat() if user.created_at else None
        },
        "complaints_count": len(complaints)
    }

@router.patch("/users/{user_id}/status")
def toggle_user_status(user_id: str, payload: dict = Body(...), token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    is_active = payload.get("is_active", True)
    user.is_active = is_active
    db.commit()

    log_audit(db, admin, "TOGGLE_USER_STATUS", f"User:{user_id}", "SUCCESS", f"Set is_active={is_active}")
    return {"success": True, "message": f"User status updated to {'Active' if is_active else 'Suspended'}"}


# ─── 4. TRANSACTIONS MANAGEMENT ─────────────────────────────────────────────────
@router.get("/transactions")
def list_transactions(token: str = Query(...), search: Optional[str] = None, db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    query = db.query(Transaction)
    if search:
        query = query.filter((Transaction.recipient_name.ilike(f"%{search}%")) | (Transaction.recipient_account_number.ilike(f"%{search}%")))
    txns = query.order_by(Transaction.created_at.desc()).all()

    return {
        "success": True,
        "transactions": [
            {
                "id": t.id,
                "sender_account_id": t.sender_account_id,
                "recipient_name": t.recipient_name,
                "recipient_account_number": t.recipient_account_number,
                "recipient_bank": t.recipient_bank,
                "amount": t.amount,
                "description": t.description,
                "status": t.status.value if hasattr(t.status, 'value') else str(t.status),
                "created_at": t.created_at.isoformat() if t.created_at else None
            } for t in txns
        ]
    }


# ─── 5. COMPLAINT MANAGEMENT ─────────────────────────────────────────────────────
@router.get("/complaints")
def list_complaints(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    complaints = db.query(Complaint).order_by(Complaint.created_at.desc()).all()

    # Seed dummy complaint if empty for demo
    if len(complaints) == 0:
        c1 = Complaint(
            user_id="U1024",
            title="Failed Transfer of ₹5,000",
            description="Amount deducted from account but beneficiary did not receive credit.",
            amount=5000.0,
            priority=ComplaintPriority.HIGH,
            status=ComplaintStatus.OPEN
        )
        db.add(c1)
        db.commit()
        complaints = db.query(Complaint).all()

    return {
        "success": True,
        "complaints": [
            {
                "id": c.id,
                "user_id": c.user_id,
                "title": c.title,
                "description": c.description,
                "amount": c.amount,
                "priority": c.priority.value if hasattr(c.priority, 'value') else str(c.priority),
                "status": c.status.value if hasattr(c.status, 'value') else str(c.status),
                "assigned_officer_id": c.assigned_officer_id,
                "internal_notes": c.internal_notes,
                "created_at": c.created_at.isoformat() if c.created_at else None
            } for c in complaints
        ]
    }

@router.patch("/complaints/{complaint_id}")
def update_complaint(complaint_id: str, payload: dict = Body(...), token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    c = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Complaint not found")

    if "status" in payload:
        c.status = ComplaintStatus(payload["status"])
    if "priority" in payload:
        c.priority = ComplaintPriority(payload["priority"])
    if "internal_notes" in payload:
        c.internal_notes = payload["internal_notes"]

    db.commit()
    log_audit(db, admin, "UPDATE_COMPLAINT", f"Complaint:{complaint_id}", "SUCCESS", f"Updated status to {c.status.value}")
    return {"success": True, "message": "Complaint updated successfully"}


# ─── 6. REQUEST MANAGEMENT ─────────────────────────────────────────────────────
@router.get("/requests")
def list_service_requests(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    requests = db.query(ServiceRequest).order_by(ServiceRequest.created_at.desc()).all()
    if len(requests) == 0:
        r1 = ServiceRequest(
            user_id="U1088",
            category="KYC Verification",
            description="Submitted Aadhaar card copy for limit enhancement to ₹1,00,000.",
            status=ServiceRequestStatus.PENDING
        )
        db.add(r1)
        db.commit()
        requests = db.query(ServiceRequest).all()

    return {
        "success": True,
        "requests": [
            {
                "id": r.id,
                "user_id": r.user_id,
                "category": r.category,
                "description": r.description,
                "status": r.status.value if hasattr(r.status, 'value') else str(r.status),
                "resolution": r.resolution,
                "created_at": r.created_at.isoformat() if r.created_at else None
            } for r in requests
        ]
    }


# ─── 7. RISK & FRAUD DASHBOARD ──────────────────────────────────────────────────
@router.get("/risk/events")
def list_risk_events(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    events = db.query(RiskEvent).order_by(RiskEvent.created_at.desc()).all()
    if len(events) == 0:
        e1 = RiskEvent(
            transaction_id="TXN9901",
            user_id="U1042",
            risk_level=RiskLevel.HIGH,
            risk_score=0.92,
            reason="Unusual location transfer & sudden high value transaction (Isolation Forest Anomaly)",
            status="FLAGGED"
        )
        db.add(e1)
        db.commit()
        events = db.query(RiskEvent).all()

    return {
        "success": True,
        "risk_events": [
            {
                "id": e.id,
                "transaction_id": e.transaction_id,
                "user_id": e.user_id,
                "risk_level": e.risk_level.value if hasattr(e.risk_level, 'value') else str(e.risk_level),
                "risk_score": e.risk_score,
                "reason": e.reason,
                "status": e.status,
                "created_at": e.created_at.isoformat() if e.created_at else None
            } for e in events
        ]
    }


# ─── 8. SECURITY EVENTS ────────────────────────────────────────────────────────
@router.get("/security/events")
def list_security_events(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    events = db.query(SecurityEvent).order_by(SecurityEvent.created_at.desc()).all()
    if len(events) == 0:
        s1 = SecurityEvent(
            user_id="U1011",
            event_type="New Device Login",
            severity="WARNING",
            description="Login attempt from unauthorized Android device ID 88A92...",
            ip_address="192.168.1.45",
            device_info="Redmi Note 12 Pro"
        )
        db.add(s1)
        db.commit()
        events = db.query(SecurityEvent).all()

    return {
        "success": True,
        "security_events": [
            {
                "id": s.id,
                "user_id": s.user_id,
                "event_type": s.event_type,
                "severity": s.severity,
                "description": s.description,
                "ip_address": s.ip_address,
                "device_info": s.device_info,
                "created_at": s.created_at.isoformat() if s.created_at else None
            } for s in events
        ]
    }


# ─── 9. AUDIT LOGS ────────────────────────────────────────────────────────────
@router.get("/audit-logs")
def list_audit_logs(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    logs = db.query(AuditLog).order_by(AuditLog.created_at.desc()).all()
    return {
        "success": True,
        "audit_logs": [
            {
                "id": a.id,
                "admin_id": a.admin_id,
                "admin_name": a.admin_name,
                "action": a.action,
                "resource": a.resource,
                "result": a.result,
                "details": a.details,
                "created_at": a.created_at.isoformat() if a.created_at else None
            } for a in logs
        ]
    }


# ─── 10. ADMIN MANAGEMENT (SUPER ADMIN ONLY) ──────────────────────────────────
@router.get("/admins")
def list_admins(token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    admins = db.query(Admin).order_by(Admin.created_at.desc()).all()
    return {
        "success": True,
        "admins": [
            {
                "id": a.id,
                "full_name": a.full_name,
                "email": a.email,
                "role": a.role.value if hasattr(a.role, 'value') else str(a.role),
                "is_active": a.is_active,
                "created_at": a.created_at.isoformat() if a.created_at else None
            } for a in admins
        ]
    }

@router.post("/admins")
def create_admin(payload: dict = Body(...), token: str = Query(...), db: Session = Depends(get_db)):
    admin = get_current_admin(token, db)
    if admin.role != AdminRole.SUPER_ADMIN:
        raise HTTPException(status_code=403, detail="Only Super Admin can create new admin users")

    full_name = payload.get("full_name")
    email = payload.get("email")
    password = payload.get("password")
    role_str = payload.get("role", "OPERATIONS_OFFICER")

    if db.query(Admin).filter(Admin.email == email).first():
        raise HTTPException(status_code=400, detail="Admin with this email already exists")

    new_admin = Admin(
        full_name=full_name,
        email=email,
        password_hash=hash_password(password),
        role=AdminRole(role_str),
        is_active=True
    )
    db.add(new_admin)
    db.commit()

    log_audit(db, admin, "CREATE_ADMIN", f"Admin:{email}", "SUCCESS", f"Created admin with role {role_str}")
    return {"success": True, "message": "Admin user created successfully"}
