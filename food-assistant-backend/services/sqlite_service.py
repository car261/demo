import os
import sqlite3
from datetime import datetime, timezone
from typing import List, Dict, Optional

from config import Config


def _get_db_path() -> str:
    base_dir = os.path.dirname(os.path.dirname(__file__))
    data_dir = os.path.join(base_dir, "data")
    os.makedirs(data_dir, exist_ok=True)
    return os.path.join(data_dir, Config.SQLITE_PATH)


def _get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(_get_db_path(), check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn


def _ensure_tables(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS chats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            message TEXT,
            is_user INTEGER,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            name TEXT,
            email TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    conn.commit()


def save_message(
    user_id: str,
    message: str,
    is_user: bool,
    timestamp: Optional[datetime] = None,
) -> None:
    conn = _get_connection()
    try:
        _ensure_tables(conn)
        ts = timestamp or datetime.now(timezone.utc)
        conn.execute(
            """
            INSERT INTO chats (user_id, message, is_user, timestamp)
            VALUES (?, ?, ?, ?)
            """,
            (str(user_id), message, 1 if is_user else 0, ts.isoformat()),
        )
        conn.commit()
    finally:
        conn.close()


def get_chat_history(user_id: str, limit: int = 200) -> List[Dict[str, str]]:
    conn = _get_connection()
    try:
        _ensure_tables(conn)
        cursor = conn.execute(
            """
            SELECT message, is_user, timestamp
            FROM chats
            WHERE user_id = ?
            ORDER BY timestamp ASC, id ASC
            LIMIT ?
            """,
            (str(user_id), limit),
        )
        rows = cursor.fetchall()
        return [
            {
                "message": row["message"],
                "is_user": bool(row["is_user"]),
                "timestamp": row["timestamp"],
            }
            for row in rows
        ]
    finally:
        conn.close()


def get_user_by_username(username: str) -> Optional[Dict[str, str]]:
    conn = _get_connection()
    try:
        _ensure_tables(conn)
        cursor = conn.execute(
            """
            SELECT id, username, password, name, email, created_at
            FROM users
            WHERE username = ?
            """,
            (username,),
        )
        row = cursor.fetchone()
        return dict(row) if row else None
    finally:
        conn.close()


def create_user(
    username: str,
    password_hash: str,
    name: str,
    email: str,
) -> Dict[str, str]:
    conn = _get_connection()
    try:
        _ensure_tables(conn)
        conn.execute(
            """
            INSERT INTO users (username, password, name, email, created_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (username, password_hash, name, email, datetime.now(timezone.utc).isoformat()),
        )
        conn.commit()
        cursor = conn.execute(
            """
            SELECT id, username, password, name, email, created_at
            FROM users
            WHERE username = ?
            """,
            (username,),
        )
        row = cursor.fetchone()
        return dict(row) if row else {}
    finally:
        conn.close()
