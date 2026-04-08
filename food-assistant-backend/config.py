import os
from datetime import timedelta


class Config:
    # Core secrets / tokens
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev_secret")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(
        days=int(os.getenv("JWT_ACCESS_TOKEN_DAYS", "7"))
    )

    # Database
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/chatgpt_clone")

    # Cache
    REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
    REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))

    # SQLite
    SQLITE_PATH = os.getenv("SQLITE_PATH", "chat.db")

    # Flask / CORS options (can be overridden via env if needed)
    JSON_SORT_KEYS = False