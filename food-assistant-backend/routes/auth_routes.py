from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

from services.db import users_col


auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    username = (data.get("username") or "").strip()
    password = data.get("password")

    if not username or not password:
        return (
            jsonify(
                error="Username and password are required",
                fields=["username", "password"],
            ),
            400,
        )

    if users_col.find_one({"username": username}):
        return (
            jsonify(
                error="User already exists",
                field="username",
            ),
            409,
        )

    hashed_pw = generate_password_hash(password)

    users_col.insert_one({"username": username, "password": hashed_pw})

    return (
        jsonify(
            message="Registered successfully",
            username=username,
        ),
        201,
    )


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}

    username = (data.get("username") or "").strip()
    password = data.get("password")

    if not username or not password:
        return (
            jsonify(
                error="Username and password are required",
                fields=["username", "password"],
            ),
            400,
        )

    user = users_col.find_one({"username": username})

    if not user or not check_password_hash(user["password"], password):
        return (
            jsonify(
                error="Invalid credentials",
                field="username",
            ),
            401,
        )

    token = create_access_token(identity=username)

    # Shape matches the requested example: { "access_token": "..." }
    return jsonify(access_token=token), 200