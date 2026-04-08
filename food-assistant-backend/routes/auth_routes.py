from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

from services.db import users_col
from services.response import success_response, error_response


auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/signup", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    username = (data.get("username") or "").strip()
    password = data.get("password")

    if not username or not password:
        return error_response("Username and password are required", 400)

    if users_col.find_one({"username": username}):
        return error_response("User already exists", 409)

    hashed_pw = generate_password_hash(password)

    users_col.insert_one({"username": username, "password": hashed_pw})

    return success_response({
        "message": "Registered successfully",
        "username": username
    }, 201)


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}

    username = (data.get("username") or "").strip()
    password = data.get("password")

    if not username or not password:
        return error_response("Username and password are required", 400)

    user = users_col.find_one({"username": username})

    if not user or not check_password_hash(user["password"], password):
        return error_response("Invalid credentials", 401)

    token = create_access_token(identity=username)

    return success_response({
        "access_token": token,
        "username": username
    })