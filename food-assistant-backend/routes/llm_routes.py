from flask import Blueprint, request
from flask_jwt_extended import get_jwt_identity, jwt_required

from services.db import get_chat_history, save_chat_message
from services.demo_ai import generate_response
from services.response import api_response

llm_bp = Blueprint("llm", __name__)

@llm_bp.route("/chat", methods=["POST"])
@jwt_required()
def chat():
    user_id = get_jwt_identity()
    data = request.get_json(silent=True) or {}
    message = (data.get("message") or "").strip()

    if not message:
        return api_response(None, "Message is required", 400, False)

    # Save user message
    save_chat_message(user_id, message, 1)

    # Generate reply
    reply = generate_response(message)

    # Save bot reply
    save_chat_message(user_id, reply, 0)

    return api_response({"reply": reply, "assistant": reply}, "Success")

@llm_bp.route("/history", methods=["GET"])
@jwt_required()
def history():
    user_id = get_jwt_identity()
    chats = get_chat_history(user_id)

    formatted = []
    for row in chats:
        msg = row[0]
        is_user = row[1]
        timestamp = row[2] if len(row) > 2 else None
        formatted.append(
            {
                "message": msg,
                "is_user": is_user,
                "timestamp": timestamp,
            }
        )

    return api_response({"chats": formatted, "messages": formatted}, "Success")