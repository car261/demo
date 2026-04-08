from functools import wraps
from typing import Callable, Optional

from flask import g, request

from services.jwt_service import JwtExpiredError, JwtInvalidError, verify_token
from services.response import error_response


def _extract_bearer_token() -> Optional[str]:
    auth_header = request.headers.get("Authorization", "")
    if not auth_header:
        return None

    parts = auth_header.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        return None

    return parts[1]


def require_auth(handler: Callable):
    """Ensure the request has a valid JWT and attach user_id to the request."""

    @wraps(handler)
    def wrapper(*args, **kwargs):
        token = _extract_bearer_token()
        if not token:
            return error_response("Authorization required", 401)

        try:
            payload = verify_token(token)
        except JwtExpiredError:
            return error_response("Token has expired", 401)
        except JwtInvalidError:
            return error_response("Invalid token", 401)

        user_id = payload.get("user_id")
        if not user_id:
            return error_response("Invalid token", 401)

        g.user_id = str(user_id)
        setattr(request, "user_id", g.user_id)
        return handler(*args, **kwargs)

    return wrapper
