from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os
from urllib.parse import urlparse, urlencode, parse_qs, urlunparse

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")


def _clean_database_url(url: str) -> str:
    """
    Remove parameters unsupported by psycopg2 (e.g. channel_binding)
    and ensure sslmode=require is present.
    """
    parsed = urlparse(url)
    params = parse_qs(parsed.query, keep_blank_values=True)

    # Remove channel_binding — psycopg2 doesn't support it and it breaks SSL
    params.pop("channel_binding", None)

    # Ensure sslmode is set to require
    params["sslmode"] = ["require"]

    new_query = urlencode({k: v[0] for k, v in params.items()})
    cleaned = urlunparse((
        parsed.scheme,
        parsed.netloc,
        parsed.path,
        parsed.params,
        new_query,
        parsed.fragment
    ))
    return cleaned


_db_url = _clean_database_url(DATABASE_URL)

# NeonDB serverless pooler — use conservative pool settings
engine = create_engine(
    _db_url,
    pool_pre_ping=True,      # Test connection before use
    pool_size=5,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=300,        # Recycle connections every 5 min
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()