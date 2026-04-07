from typing import Any, Optional

import redis

from config import Config


class CacheClient:
    """Small Redis wrapper with safe helpers for app use.

    - Uses decode_responses=True so callers always get str values.
    - Swallows connection errors and returns sensible defaults instead
      of crashing the application.
    """

    def __init__(self) -> None:
        self._client = redis.Redis(
            host=Config.REDIS_HOST,
            port=Config.REDIS_PORT,
            decode_responses=True,
        )

    def get(self, key: str, default: Optional[Any] = None) -> Optional[str]:
        try:
            value = self._client.get(key)
        except redis.RedisError:
            return default
        return value if value is not None else default

    def setex(self, key: str, ttl_seconds: int, value: Any) -> None:
        try:
            self._client.setex(key, ttl_seconds, value)
        except redis.RedisError:
            # Intentionally ignore cache write failures so the
            # main application flow is not affected.
            return

    def ping(self) -> bool:
        """Return True if Redis is reachable, False otherwise."""

        try:
            self._client.ping()
            return True
        except redis.RedisError:
            return False


# Singleton cache instance used across the app
cache = CacheClient()