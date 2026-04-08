import os
import tempfile

from flask import Blueprint, request

from services.chat_ai import set_latest_prediction
from services.demo_ai import predict_image
from services.response import success_response, error_response


predict_bp = Blueprint("predict", __name__)


@predict_bp.route("/predict", methods=["POST"])
def predict():
    """Handle image upload and return nutrition prediction.

    Expects multipart/form-data with field name "image".
    Returns standard response format with prediction data.
    """
    temp_path = None
    try:
        image_file = request.files.get("image")

        # Validate that the image file is present and has a filename
        if image_file is None or image_file.filename == "":
            return error_response("No image uploaded", 400)

        from werkzeug.utils import secure_filename
        filename = secure_filename(image_file.filename) or "upload.jpg"
        temp_dir = tempfile.mkdtemp(prefix="food_upload_")
        temp_path = os.path.join(temp_dir, filename)
        image_file.save(temp_path)

        prediction = predict_image(temp_path)
        set_latest_prediction(prediction)

        # Use standard response format
        return success_response(prediction, 200)
    except Exception as exc:
        return error_response(f"Prediction failed: {str(exc)}", 500)
    finally:
        if temp_path and os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except OSError:
                pass