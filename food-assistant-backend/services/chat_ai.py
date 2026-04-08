import json
from datetime import datetime, timezone

from services.cache import cache
from services.db import get_chats_collection
from services.sqlite_service import save_message, get_chat_history as get_sqlite_history

LATEST_PREDICTION_KEY = "latest_prediction"
_latest_prediction = None

# keyword groups (acts like simple NLP)
INTENTS = {
    "greeting": ["hello", "hi", "hey"],
    "calories": ["calories", "kcal", "energy"],
    "protein": ["protein", "proteins"],
    "ingredients": ["ingredients", "what is in", "contains"],
    "health": ["healthy", "diet", "good for health", "good for me"],
}


def detect_intent(message: str) -> str:
    msg = message.lower()

    for intent, keywords in INTENTS.items():
        if any(word in msg for word in keywords):
            return intent

    return "unknown"


def set_latest_prediction(prediction: dict) -> None:
    global _latest_prediction
    _latest_prediction = prediction
    try:
        cache.setex(LATEST_PREDICTION_KEY, 6 * 60 * 60, json.dumps(prediction))
    except TypeError:
        # Skip cache write if prediction isn't JSON-serializable.
        return


def get_latest_prediction() -> dict | None:
    global _latest_prediction
    cached_value = cache.get(LATEST_PREDICTION_KEY)
    if isinstance(cached_value, str):
        try:
            _latest_prediction = json.loads(cached_value)
        except json.JSONDecodeError:
            return _latest_prediction
    return _latest_prediction


def _format_ingredients(ingredients: list | None) -> str:
    if not ingredients:
        return "No ingredients found yet."
    return ", ".join(ingredients)


def _health_summary(calories: float | int | None, protein: float | int | None) -> str:
    if calories is None or protein is None:
        return "I need calories and protein to give a health summary."

    if calories <= 450 and protein >= 15:
        return "Looks fairly balanced. Great choice with a veggie side."
    if calories >= 700:
        return "Likely heavy. Consider a smaller portion or lighter sides."
    if protein < 10:
        return "A bit low on protein. Add a lean protein if you can."
    return "Seems okay. Watch portions and add veggies for balance."


def generate_response(user_message: str, prediction: dict | None) -> str:
    intent = detect_intent(user_message)

    if not prediction:
        if intent == "greeting":
            return "Hey! Ask me about calories, protein, or ingredients."
        if intent in {"calories", "protein", "ingredients", "health"}:
            return "I can help once you analyze a food item."
        return "Ask me about calories, protein, ingredients, or healthiness."

    dish_name = prediction.get("dish_name") or "this dish"
    ingredients = prediction.get("ingredients", [])
    calories = prediction.get("calories")
    protein = prediction.get("protein")

    if intent == "greeting":
        reply = "Hey! Ask me about calories, protein, or ingredients."
    elif intent == "calories":
        if calories is None:
            reply = "I don't have calorie info yet."
        else:
            reply = f"{dish_name} has about {calories} kcal per serving."
    elif intent == "protein":
        if protein is None:
            reply = "I don't have protein info yet."
        else:
            reply = f"{dish_name} has about {protein} g of protein."
    elif intent == "ingredients":
        reply = f"Ingredients: {_format_ingredients(ingredients)}."
    elif intent == "health":
        reply = _health_summary(calories, protein)
    else:
        reply = "Ask me about calories, protein, ingredients, or healthiness."

    return reply


def _serialize_chat(chat_doc: dict) -> dict:
    created_at = chat_doc.get("created_at")
    if isinstance(created_at, datetime):
        created_at = created_at.isoformat()

    messages = []
    for message in chat_doc.get("messages", []):
        timestamp = message.get("timestamp")
        if isinstance(timestamp, datetime):
            timestamp = timestamp.isoformat()
        messages.append({
            "role": message.get("role"),
            "content": message.get("content"),
            "timestamp": timestamp,
        })

    return {
        "id": str(chat_doc.get("_id")),
        "user_id": str(chat_doc.get("user_id")),
        "messages": messages,
        "created_at": created_at,
    }


def store_chat_message(user_id: str, user_message: str, assistant_message: str) -> dict:
    chats_col = get_chats_collection()
    now = datetime.now(timezone.utc)

    save_message(user_id, user_message, True, timestamp=now)
    save_message(user_id, assistant_message, False, timestamp=now)

    chat_doc = {
        "user_id": str(user_id),
        "messages": [
            {
                "role": "user",
                "content": user_message,
                "timestamp": now,
            },
            {
                "role": "assistant",
                "content": assistant_message,
                "timestamp": now,
            },
        ],
        "created_at": now,
    }

    result = chats_col.insert_one(chat_doc)
    chat_doc["_id"] = result.inserted_id
    return _serialize_chat(chat_doc)


def get_chat_history(user_id: str, limit: int = 50) -> list[dict]:
    chats_col = get_chats_collection()
    cursor = (
        chats_col.find({"user_id": str(user_id)})
        .sort("created_at", -1)
        .limit(limit)
    )
    return [_serialize_chat(doc) for doc in cursor]


def get_sqlite_chat_history(user_id: str, limit: int = 200) -> list[dict]:
    return get_sqlite_history(user_id, limit=limit)