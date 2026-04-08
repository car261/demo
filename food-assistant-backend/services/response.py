from flask import jsonify


def api_response(
    data=None,
    message=None,
    status_code=200,
    success=True,
    errors=None,
):
    payload = {
        "status": "success" if success else "error",
        "data": data,
    }

    if message is not None:
        payload["message"] = message
    if errors is not None:
        payload["errors"] = errors

    return jsonify(payload), status_code


def success_response(data, status=200):
    return api_response(data=data, status_code=status, success=True)


def error_response(message, status=400):
    return api_response(
        data=None,
        message=message,
        status_code=status,
        success=False,
    )