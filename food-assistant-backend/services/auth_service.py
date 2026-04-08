from datetime import datetime, timezone
from typing import Any, Dict, Optional

import bcrypt
from werkzeug.security import check_password_hash, generate_password_hash

from services.db import get_users_collection
from services.sqlite_service import create_user as create_sqlite_user
from services.sqlite_service import get_user_by_username


class AuthServiceError(Exception):
    """Auth service error with an HTTP status code."""

    def __init__(self, message: str, status_code: int = 400) -> None:
        super().__init__(message)
        self.status_code = status_code


def _hash_password(password: str) -> str:
    return generate_password_hash(password)


def _verify_password(password: str, stored_hash: str) -> bool:
    if stored_hash.startswith("$2"):
        return bcrypt.checkpw(password.encode("utf-8"), stored_hash.encode("utf-8"))
    return check_password_hash(stored_hash, password)


def _serialize_user(user: Dict[str, Any]) -> Dict[str, Any]:
    created_at = user.get("created_at")
    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()
    return {
        "id": str(user.get("id") or user.get("_id")),
        "name": user.get("name", ""),
        "email": user.get("email") or user.get("username", ""),
        "created_at": created_at,
    }


def get_user_by_email(email: str) -> Optional[Dict[str, Any]]:
    username = email.strip().lower()
    user = get_user_by_username(username)
    if user:
        return user

    try:
        users_col = get_users_collection()
        return users_col.find_one({"email": username})
    except Exception:
        return None


def create_user(name: str, email: str, password: str) -> Dict[str, Any]:
    email_normalized = email.strip().lower()

    if get_user_by_username(email_normalized):
        raise AuthServiceError("User already exists", 409)

    user_doc = create_sqlite_user(
        username=email_normalized,
        password_hash=_hash_password(password),
        name=name.strip(),
        email=email_normalized,
    )
    return _serialize_user(user_doc)


def authenticate_user(email: str, password: str) -> Optional[Dict[str, Any]]:
    email_normalized = email.strip().lower()
    user = get_user_by_email(email_normalized)

    if not user:
        return None

    if not _verify_password(password, user.get("password", "")):
        return None

    if user.get("id") is not None:
        return _serialize_user(user)

    try:
        user_doc = create_sqlite_user(
            username=email_normalized,
            password_hash=user.get("password", ""),
            name=user.get("name", email_normalized.split("@")[0]),
            email=email_normalized,
        )
        return _serialize_user(user_doc)
    except Exception:
        return _serialize_user(user)
