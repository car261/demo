from typing import Optional

from pymongo import MongoClient
from pymongo.errors import PyMongoError

from config import Config


_client: Optional[MongoClient] = None
_db = None


def _create_client() -> MongoClient:
	"""Create and verify a MongoDB client.

	Uses a short server selection timeout and performs a ping so that
	connection issues are discovered early and raised with a clear error.
	"""

	try:
		client = MongoClient(Config.MONGO_URI, serverSelectionTimeoutMS=5000)
		# Trigger server selection to validate the URI/connection.
		client.admin.command("ping")
		return client
	except PyMongoError as exc:
		# Let the application decide how to surface this (e.g., 5xx JSON).
		raise RuntimeError("Could not connect to MongoDB") from exc


def get_client() -> MongoClient:
	"""Return a singleton MongoClient instance, creating it on first use."""

	global _client
	if _client is None:
		_client = _create_client()
	return _client


def get_db():
	"""Return the application's MongoDB database object.

	If the URI includes a database name, that is used; otherwise the
	"chatgpt_clone" database is returned by default.
	"""

	global _db
	if _db is None:
		client = get_client()
		db = client.get_default_database()
		if db is None:
			db = client["chatgpt_clone"]
		_db = db
	return _db


def get_users_collection():
	"""Convenience accessor for the users collection."""

	return get_db()["users"]


def get_chats_collection():
	"""Convenience accessor for the chats collection."""

	return get_db()["chats"]


# Backwards-compatible aliases for existing imports in routes
users_col = get_users_collection()
chats_col = get_chats_collection()