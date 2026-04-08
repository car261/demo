import json

from services.cache import cache

chat_history = []

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
        return "Please analyze a food item first."

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

    chat_history.append({
        "user": user_message,
        "assistant": reply,
        "intent": intent,
    })

    return reply