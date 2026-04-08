import random


DEMO_PREDICTIONS = [
    {
        "dish_name": "Veggie Fried Rice",
        "ingredients": ["rice", "egg", "carrot", "peas", "soy sauce"],
        "calories": 420,
        "protein": 14,
        "confidence": 0.82,
    },
    {
        "dish_name": "Grilled Chicken Salad",
        "ingredients": ["chicken", "lettuce", "tomato", "cucumber", "olive oil"],
        "calories": 360,
        "protein": 28,
        "confidence": 0.88,
    },
    {
        "dish_name": "Paneer Tikka",
        "ingredients": ["paneer", "yogurt", "spices", "onion", "capsicum"],
        "calories": 480,
        "protein": 22,
        "confidence": 0.79,
    },
]


def predict_image(file_path: str) -> dict:
    """Mock AI prediction for an uploaded image.

    Replace the implementation with a real model later. The signature
    keeps integration simple for future swaps.
    """
    _ = file_path
    return random.choice(DEMO_PREDICTIONS).copy()
