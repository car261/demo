from flask import jsonify

def success_response(data, status=200):
    return jsonify({
        "status": "success",
        "data": data
    }), status

def error_response(message, status=400):
    return jsonify({
        "status": "error",
        "message": message
    }), status