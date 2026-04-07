from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

from services.cache import cache
from services.db import chats_col


llm_bp = Blueprint("llm", __name__)


@llm_bp.route("/ask", methods=["POST"])
@jwt_required()
def ask():
    """Handle chat questions from the Flutter app.

    Request JSON: { "query": "text" }
    Response JSON on success: { "response": "text", "source": "cache"|"llm" }
    """
    try:
        user = get_jwt_identity()
        data = request.get_json(silent=True) or {}

        query = (data.get("query") or "").strip()
        if not query:
            return (
                jsonify(error="Field 'query' is required", field="query"),
                400,
            )

        cache_key = f"{user}:{query}"

        cached = cache.get(cache_key)
        if cached:
            return jsonify(response=cached, source="cache"), 200

        # TODO: Replace this stub with a real LLM integration.
        response_text = f"Hello {user}, response for {query}"

        # Cache the result for future identical queries
        cache.setex(cache_key, 3600, response_text)

        # Persist the chat for history/analytics
        chats_col.insert_one(
            {
                "user": user,
                "query": query,
                "response": response_text,
            }
        )

        return jsonify(response=response_text, source="llm"), 200
    except Exception as exc:  # pragma: no cover - defensive catch
        # Log the full exception server-side while returning a safe JSON payload.
        current_app.logger.exception("Unhandled error in /ask: %s", exc)
        return (
            jsonify(error="Internal server error", route="/ask"),
            500,
        )