from flask import Blueprint, request, jsonify


predict_bp = Blueprint("predict", __name__)


@predict_bp.route("/predict", methods=["POST"])
def predict():
    """Handle image upload from Flutter and return ingredients.

    Expects multipart/form-data with field name "image".
    Successful response JSON: { "ingredients": ["rice", "egg", "tomato"] }
    """
    image_file = request.files.get("image")

    # Validate that the image file is present and has a filename
    if image_file is None or image_file.filename == "":
        return (
            jsonify(
                error="No image uploaded",
                field="image",
            ),
            400,
        )

    # TODO: Replace this stub with a real image recognition model.
    detected_ingredients = ["rice", "egg", "tomato"]

    # Simple, Flutter-friendly payload
    return jsonify(ingredients=detected_ingredients), 200