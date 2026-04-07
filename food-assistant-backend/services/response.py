from flask import jsonify


def api_response(*, data=None, message="", status_code=200, success=True, errors=None):
    """Standard JSON response wrapper for frontend-friendly APIs.

    All responses follow the shape:
    {
        "success": bool,
        "message": str,
        "data": any,
        "errors": any
    }
    """
    payload = {
        "success": success,
        "message": message,
        "data": data,
        "errors": errors,
    }
    return jsonify(payload), status_code
