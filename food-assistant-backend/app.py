import os

from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from werkzeug.exceptions import HTTPException

from config import Config
from routes.auth_routes import auth_bp
from routes.llm_routes import llm_bp
from routes.predict_routes import predict_bp
from services.response import api_response


app = Flask(__name__)
app.config.from_object(Config)

# Enable CORS for all origins (Flutter web + emulators)
CORS(
    app,
    resources={r"/*": {"origins": "*"}},
    supports_credentials=True,
    expose_headers=["Authorization"],
    allow_headers=["Content-Type", "Authorization"],
)


# JWT setup
jwt = JWTManager(app)


@jwt.unauthorized_loader
def handle_missing_jwt(reason: str):
    return api_response(
        data=None,
        message="Authorization required",
        status_code=401,
        success=False,
        errors={"reason": reason},
    )


@jwt.invalid_token_loader
def handle_invalid_jwt(reason: str):
    return api_response(
        data=None,
        message="Invalid token",
        status_code=422,
        success=False,
        errors={"reason": reason},
    )


@jwt.expired_token_loader
def handle_expired_jwt(jwt_header, jwt_data):
    return api_response(
        data=None,
        message="Token has expired",
        status_code=401,
        success=False,
        errors={"token_type": jwt_data.get("type")},
    )


@jwt.needs_fresh_token_loader
def handle_needs_fresh_jwt(reason: str):
    return api_response(
        data=None,
        message="Fresh token required",
        status_code=401,
        success=False,
        errors={"reason": reason},
    )


@jwt.revoked_token_loader
def handle_revoked_jwt(jwt_header, jwt_data):
    return api_response(
        data=None,
        message="Token has been revoked",
        status_code=401,
        success=False,
        errors={"jti": jwt_data.get("jti")},
    )


@app.errorhandler(HTTPException)
def handle_http_exception(exc: HTTPException):
    return api_response(
        data=None,
        message=exc.description or exc.name,
        status_code=exc.code or 500,
        success=False,
        errors={"code": exc.code, "name": exc.name},
    )


@app.errorhandler(Exception)
def handle_unexpected_exception(exc: Exception):
    # In production you would log the full exception here.
    return api_response(
        data=None,
        message="Internal server error",
        status_code=500,
        success=False,
        errors={"type": exc.__class__.__name__},
    )


# Register routes
app.register_blueprint(auth_bp)
app.register_blueprint(llm_bp)
app.register_blueprint(predict_bp)


@app.route("/health", methods=["GET"])
def health() -> tuple[dict, int]:
    """Simple health check for containers and external clients.

    Returns a minimal JSON body so tools like Flutter or Docker healthchecks
    can verify the backend is reachable.
    """
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    # Bind to all interfaces so Docker and external clients can reach the app
    # and use the fixed port 5000 as required.
    app.run(host="0.0.0.0", port=5000)