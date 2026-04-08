from typing import Optional
from pymongo import MongoClient
from pymongo.errors import PyMongoError
from config import Config

import sqlite3
import os

# ---------------- MONGO (EXISTING - KEEP) ----------------

_client: Optional[MongoClient] = None
_db = None

def _create_client() -> MongoClient:
    try:
        client = MongoClient(Config.MONGO_URI, serverSelectionTimeoutMS=5000)
        client.admin.command("ping")
        return client
    except PyMongoError as exc:
        raise RuntimeError("Could not connect to MongoDB") from exc

def get_client() -> MongoClient:
    global _client
    if _client is None:
        _client = _create_client()
    return _client

def get_db():
    global _db
    if _db is None:
        client = get_client()
        db = client.get_default_database()
        if db is None:
            db = client["chatgpt_clone"]
        _db = db
    return _db

def get_users_collection():
    return get_db()["users"]

def get_chats_collection():
    return get_db()["chats"]

users_col = get_users_collection()
chats_col = get_chats_collection()

# ---------------- SQLITE (ADDED SAFE) ----------------


def _get_sqlite_path() -> str:
    os.makedirs("data", exist_ok=True)
    configured_name = getattr(Config, "SQLITE_PATH", "chat.db") or "chat.db"
    return os.path.join("data", configured_name)


def _init_sqlite_schema(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS chats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            message TEXT,
            is_user INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    conn.commit()


def save_chat_message(user_id: str, message: str, is_user: int):
    with sqlite3.connect(_get_sqlite_path()) as conn:
        _init_sqlite_schema(conn)
        conn.execute(
            "INSERT INTO chats (user_id, message, is_user) VALUES (?, ?, ?)",
            (str(user_id), message, int(is_user)),
        )
        conn.commit()


def get_chat_history(user_id: str):
    with sqlite3.connect(_get_sqlite_path()) as conn:
        _init_sqlite_schema(conn)
        cursor = conn.execute(
            "SELECT message, is_user, timestamp FROM chats WHERE user_id=? ORDER BY timestamp ASC, id ASC",
            (str(user_id),),
        )
        rows = cursor.fetchall()
    return rows