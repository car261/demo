def generate_response(user_message: str):
    msg = user_message.lower()

    if any(word in msg for word in ["hi", "hello", "hey"]):
        return "Hey! 👋 I’m your food assistant."

    elif "calories" in msg:
        return "This dish has approximately 250–400 calories."

    elif "protein" in msg:
        return "This dish contains around 10–20g protein."

    elif "healthy" in msg:
        return "It can be part of a balanced diet."

    return "Ask me about calories, protein, or food analysis."


def predict_image(file_path: str):
    """Fallback prediction used when the ML model is not wired yet."""

    return {
        "label": "demo",
        "confidence": 0.0,
        "message": "Fallback prediction (model not implemented)",
        "dish_name": "Demo Dish",
        "ingredients": [],
        "calories": None,
        "protein": None,
        "source_file": file_path,
    }