from datetime import datetime, timezone

import jwt

from config import Config


class JwtServiceError(Exception):
    """Base JWT service error."""


class JwtExpiredError(JwtServiceError):
    """Raised when a token has expired."""


class JwtInvalidError(JwtServiceError):
    """Raised when a token is invalid."""


def create_token(user_id: str) -> str:
    """Create a signed JWT for the provided user id."""

    now = datetime.now(timezone.utc)
    expires_at = now + Config.JWT_ACCESS_TOKEN_EXPIRES

    payload = {
        "user_id": str(user_id),
        "iat": int(now.timestamp()),
        "exp": int(expires_at.timestamp()),
    }

    return jwt.encode(payload, Config.JWT_SECRET_KEY, algorithm="HS256")


def verify_token(token: str) -> dict:
    """Verify a JWT and return its payload."""

    try:
        return jwt.decode(token, Config.JWT_SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError as exc:
        raise JwtExpiredError("Token has expired") from exc
    except jwt.InvalidTokenError as exc:
        raise JwtInvalidError("Invalid token") from exc
