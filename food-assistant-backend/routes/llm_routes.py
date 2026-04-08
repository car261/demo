from flask import Blueprint, request

from services.chat_ai import generate_response, get_latest_prediction
from services.response import success_response, error_response

llm_bp = Blueprint("llm", __name__)

@llm_bp.route("/chat", methods=["POST"])
def chat():
    """Handle chat messages and return AI-generated responses.
    
    Expects JSON:
    {
        "message": "user question here"
    }
    
    Returns:
    {
        "status": "success",
        "data": {
            "user": "user question",
            "assistant": "AI response"
        }
    }
    """
    try:
        data = request.get_json()

        if not data or "message" not in data:
            return error_response("Message is required", 400)

        user_message = str(data["message"]).strip()
        if not user_message:
            return error_response("Message is required", 400)

        prediction = get_latest_prediction()
        reply = generate_response(user_message, prediction)

        return success_response({
            "user": user_message,
            "assistant": reply
        })

    except Exception as e:
        return error_response(str(e), 500)