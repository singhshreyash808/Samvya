from datetime import datetime, timedelta
import os

from dotenv import load_dotenv
from jose import JWTError, jwt
from passlib.context import CryptContext

load_dotenv()

SECRET_KEY = os.getenv(
    "SECRET_KEY",
    "samvya-secret-key"
)

ALGORITHM = os.getenv(
    "ALGORITHM",
    "HS256"
)

ACCESS_TOKEN_EXPIRE_DAYS = 7

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)


# ---------------- Password ---------------- #

def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(
    plain_password: str,
    hashed_password: str
) -> bool:
    return pwd_context.verify(
        plain_password,
        hashed_password
    )


# ---------------- JWT ---------------- #

def create_access_token(
    user_id: str,
    mobile: str
):

    expire = datetime.utcnow() + timedelta(
        days=ACCESS_TOKEN_EXPIRE_DAYS
    )

    payload = {
        "sub": user_id,
        "mobile": mobile,
        "type": "access",
        "exp": expire,
        "iat": datetime.utcnow()
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM
    )


def decode_token(token: str):

    try:

        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )

        return payload

    except JWTError:
        return None


def get_current_user_id(token: str):

    payload = decode_token(token)

    if payload is None:
        return None

    return payload.get("sub")