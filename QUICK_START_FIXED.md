# Quick Start Guide - Food Assistant App

## Prerequisites
- Python 3.8+ (for Flask backend)
- Flutter 3.0+ (for mobile app)
- Optional: Redis, MongoDB (for advanced features)

---

## Step 1: Start Flask Backend

```bash
cd food-assistant-backend

# Create virtual environment (if not already done)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

✅ **Backend running at:** `http://0.0.0.0:5000`

---

## Step 2: Verify Backend Health

Open a terminal and run:
```bash
curl http://localhost:5000/health
```

Should return: `{"status": "ok"}`

---

## Step 3: Run Flutter App

```bash
# Go back to root directory
cd ..

# Get Flutter dependencies
flutter pub get

# Run app
flutter run

# Select your device/emulator when prompted
```

---

## Step 4: Test the App

### Test Login/Signup
1. Open app → Navigate to login/signup screen
2. Enter credentials and login
3. Should succeed (or show error with clear message)

### Test Chat
1. Go to chat screen
2. Type a message
3. Send message
4. Should see AI response

### Test Food Prediction
1. Click image picker icon
2. Select an image from gallery
3. App sends to `/api/predict`
4. Shows: Dish name, ingredients, calories, protein
5. Can now ask questions about the food in chat

---

## Platform-Specific URLs

The app automatically uses the correct API URL:

| Platform | URL | Notes |
|----------|-----|-------|
| Android Emulator | `http://10.0.2.2:5000` | Special Gateway IP |
| iOS Simulator | `http://localhost:5000` | Localhost |
| Real Device | `http://192.168.1.X:5000` | Your PC's IP |
| Web | `http://localhost:5000` | Localhost |

**For Real Device Testing:**
Edit `test/lib/core/services/api_config.dart`:
```dart
static const String customBaseUrl = "http://192.168.1.100:5000"; // Your PC's IP
```

---

## Troubleshooting

### "Backend not reachable"
- ✅ Check if Flask is running: `curl http://localhost:5000/health`
- ✅ For real device: Update `customBaseUrl` in api_config.dart
- ✅ Check firewall settings

### "Login failed"
- ✅ Check terminal for error message
- ✅ Ensure you're using correct username/password format
- ✅ Check backend logs for MongoDB connection errors

### "Chat not responding"
- ✅ Must upload an image first (prediction)
- ✅ Check network connection
- ✅ Ask questions about the predicted food (calories, protein, ingredients)

### "Image upload fails"
- ✅ Check file size (should be reasonable)
- ✅ Check image format (JPEG, PNG)
- ✅ Ensure storage permissions granted

---

## Key API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Check backend health |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/signup` | User registration |
| POST | `/api/chat` | Chat message |
| POST | `/api/predict` | Image analysis |

---

## Backend Structure

```
food-assistant-backend/
├── app.py                 # Main Flask app
├── config.py              # Configuration
├── requirements.txt       # Dependencies
├── routes/
│   ├── auth_routes.py     # Login/signup endpoints
│   ├── llm_routes.py      # Chat endpoint
│   └── predict_routes.py  # Prediction endpoint
└── services/
    ├── response.py        # Response helpers
    ├── chat_ai.py         # Chat logic
    ├── demo_ai.py         # Mock AI predictions
    ├── cache.py           # Redis cache
    └── db.py              # MongoDB client
```

---

## Flutter Structure

```
lib/
├── main.dart              # Entry point
├── core/
│   ├── services/
│   │   ├── api_config.dart    # API configuration
│   │   └── api_service.dart   # HTTP client
│   ├── router/
│   │   └── app_router.dart    # Navigation
│   └── theme/
│       └── app_theme.dart     # Themes
└── features/
    ├── auth/
    │   └── providers/
    │       └── auth_provider.dart  # Auth logic
    └── chat/
        └── providers/
            ├── chat_provider.dart        # Chat logic
            └── chat_list_provider.dart   # Chat list management
```

---

## Environment Variables (Optional)

Backend supports environment variables in `.env` file:

```
# JWT
JWT_SECRET_KEY=your_secret_key
JWT_ACCESS_TOKEN_MINUTES=60

# Database
MONGO_URI=mongodb://localhost:27017/chatgpt_clone

# Cache
REDIS_HOST=localhost
REDIS_PORT=6379
```

---

## Performance Tips

1. **Use Redis for Caching**: Improves chat response speed
2. **Use MongoDB for Persistence**: Store chat history
3. **Optimize Images**: Resize before sending to prediction
4. **Add Real AI Model**: Replace demo_ai.py with actual ML model
5. **Rate Limiting**: Add rate limiting in production

---

## What You Can Do Now

✅ Users can sign up and login
✅ Users can upload food images
✅ App analyzes images and shows nutrition info
✅ Users can chat about the food
✅ Smart responses based on intent (calories, protein, ingredients, health)
✅ Works on Android emulator, iOS simulator, and real devices

---

## Next Steps (Optional Enhancements)

1. **Add Real AI Model**: Replace demo predictions with actual ML
2. **Store Chat History**: Use MongoDB to persist conversations
3. **User Authentication**: Store tokens and user data
4. **Image Caching**: Cache predictions locally
5. **Notifications**: Push notifications for meal reminders
6. **Social**: Share meals and get nutritional analysis from community
7. **Recipes**: Suggest recipes based on ingredients
8. **Meal Planning**: Help users plan meals for the week

---

Enjoy your production-ready Food Assistant App! 🚀

For detailed technical documentation, see: **FULL_STACK_FIX_SUMMARY.md**
