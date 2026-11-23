import os
from pathlib import Path
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


load_dotenv(Path(__file__).resolve().parents[2] / ".env")

DATABASE_URL = os.getenv("DATABASE_URL", "").strip()
if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL is not configured. Add it to backend/.env before starting the API."
    )


def _normalize_database_url(url: str) -> str:
    """Normalize provider URLs and remove options unsupported by psycopg2."""
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://") :]

    parsed = urlsplit(url)
    if parsed.scheme not in {"postgresql", "postgresql+psycopg2"}:
        return url

    query = [(key, value) for key, value in parse_qsl(parsed.query, keep_blank_values=True)
             if key != "channel_binding"]
    if not any(key == "sslmode" for key, _ in query):
        query.append(("sslmode", "require"))

    return urlunsplit((
        parsed.scheme,
        parsed.netloc,
        parsed.path,
        urlencode(query),
        parsed.fragment,
    ))


DATABASE_URL = _normalize_database_url(DATABASE_URL)
_is_sqlite = DATABASE_URL.startswith("sqlite:")
_engine_options = {"pool_pre_ping": True}
if _is_sqlite:
    _engine_options["connect_args"] = {"check_same_thread": False}
else:
    _engine_options.update(pool_size=5, max_overflow=10, pool_timeout=30, pool_recycle=300)

engine = create_engine(DATABASE_URL, **_engine_options)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
