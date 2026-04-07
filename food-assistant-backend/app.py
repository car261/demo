from flask import Flask, request, jsonify
from flask_cors import CORS  # <-- Added for Flutter compatibility
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from pymongo import MongoClient
import redis
import json

app = Flask(__name__)

# 1. Enable CORS: Allow Flutter Web from any localhost port to talk to Flask
# This handles both simple requests and preflight (OPTIONS) requests.
CORS(
    app,
    resources={r"/*": {"origins": ["http://localhost", "http://localhost:*", "http://127.0.0.1", "http://127.0.0.1:*"]}},
)

# --- Configuration ---
app.config["JWT_SECRET_KEY"] = "your_super_secret_key" 
jwt = JWTManager(app)

# --- Databases ---
# Added try-except blocks so the app stays alive even if DBs are offline
try:
    mongo_client = MongoClient("mongodb://localhost:27017/", serverSelectionTimeoutMS=2000)
    db = mongo_client["food_assistant"]
    users_col = db["users"]
    chats_col = db["chats"]
    # Trigger a quick check
    mongo_client.server_info() 
except Exception as e:
    print(f"⚠️ MongoDB not connected: {e}")

try:
    cache = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True, socket_timeout=2)
except Exception as e:
    print(f"⚠️ Redis not connected: {e}")

# --- Routes ---

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    if not data or "username" not in data or "password" not in data:
        return jsonify(msg="Missing username or password"), 400
    
    # Check if user exists
    if users_col.find_one({"username": data["username"]}):
        return jsonify(msg="User already exists"), 409

    users_col.insert_one({"username": data["username"], "password": data["password"]})
    return jsonify(msg="User registered"), 201

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = users_col.find_one({"username": data["username"], "password": data["password"]})
    if user:
        # In newer Flask-JWT-Extended, 'identity' must be a string
        access_token = create_access_token(identity=str(data["username"]))
        return jsonify(access_token=access_token)
    return jsonify(msg="Invalid credentials"), 401

@app.route("/ask", methods=["POST"])
@jwt_required()
def ask_llm():
    current_user = get_jwt_identity()
    user_query = request.json.get("query")
    
    if not user_query:
        return jsonify(msg="No query provided"), 400

    # 1. Check Redis Cache First (with safety check)
    try:
        cached_response = cache.get(user_query)
        if cached_response:
            return jsonify(response=cached_response, source="cache")
    except:
        pass # Skip cache if Redis is down

    # 2. Simulated LLM Response
    response = f"Hello {current_user}! Simulated LLM response for: {user_query}" 

    # 3. Save to Redis & MongoDB (with safety checks)
    try:
        cache.setex(user_query, 3600, response)
    except:
        pass

    try:
        chats_col.insert_one({
            "user": current_user,
            "query": user_query,
            "response": response
        })
    except:
        print("Could not save chat to MongoDB")

    return jsonify(response=response, source="llm")

if __name__ == "__main__":
    # Use 0.0.0.0 to allow connections from other devices/emulators
    app.run(debug=True, host="0.0.0.0", port=5000)