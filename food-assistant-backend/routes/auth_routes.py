from flask import Blueprint, request
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

from services.db import users_col
from services.response import api_response

auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or data.get("email") or "").strip().lower()
    password = data.get("password")

    if not username or not password:
        return api_response(None, "Username/email and password are required", 400, False)

    if users_col.find_one({"username": username}):
        return api_response(None, "User already exists", 400, False)

    hashed_password = generate_password_hash(password)

    user = {
        "username": username,
        "password": hashed_password
    }

    result = users_col.insert_one(user)

    token = create_access_token(identity=str(result.inserted_id))

    return api_response(
        {"user_id": str(result.inserted_id), "token": token},
        "User registered",
        201,
        True,
    )


@auth_bp.route("/signup", methods=["POST"])
def signup_alias():
    # Backward-compatible alias for frontend clients using /signup
    return register()

@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or data.get("email") or "").strip().lower()
    password = data.get("password")

    if not username or not password:
        return api_response(None, "Username/email and password are required", 400, False)

    user = users_col.find_one({"username": username})

    if not user or not check_password_hash(user["password"], password):
        return api_response(None, "Invalid credentials", 401, False)

    token = create_access_token(identity=str(user["_id"]))

    return api_response({"token": token}, "Login successful", 200, True)