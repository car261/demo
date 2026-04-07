from flask import Flask, request, jsonify
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from pymongo import MongoClient
import redis
import json

app = Flask(__name__)

# --- Configuration ---
app.config["JWT_SECRET_KEY"] = "your_super_secret_key" # Change this!
jwt = JWTManager(app)

# --- Databases ---
# MongoDB for persistent chat history and user data
mongo_client = MongoClient("mongodb://localhost:27017/")
db = mongo_client["food_assistant"]
users_col = db["users"]
chats_col = db["chats"]

# Redis for caching LLM responses (Fast RAM access)
cache = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

# --- Routes ---

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    # Simple check: in production, hash the password!
    users_col.insert_one({"username": data["username"], "password": data["password"]})
    return jsonify(msg="User registered"), 201

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = users_col.find_one({"username": data["username"], "password": data["password"]})
    if user:
        access_token = create_access_token(identity=data["username"])
        return jsonify(access_token=access_token)
    return jsonify(msg="Invalid credentials"), 401

@app.route("/ask", methods=["POST"])
@jwt_required()
def ask_llm():
    current_user = get_jwt_identity()
    user_query = request.json.get("query")

    # 1. Check Redis Cache First
    cached_response = cache.get(user_query)
    if cached_response:
        return jsonify(response=cached_response, source="cache")

    # 2. Call your pre-built LLM model here
    # Example: response = my_llm_model.generate(user_query)
    response = f"Simulated LLM response for: {user_query}" 

    # 3. Save to Redis (expire in 1 hour)
    cache.setex(user_query, 3600, response)

    # 4. Save to MongoDB History
    chats_col.insert_one({
        "user": current_user,
        "query": user_query,
        "response": response
    })

    return jsonify(response=response, source="llm")

if __name__ == "__main__":
    app.run(debug=True, port=5000)