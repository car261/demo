# Flutter ChatGPT Clone - Complete Setup Guide

## Quick Start (Automated)

### Option 1: Windows Users
```cmd
1. Double-click SETUP.bat
2. Follow the prompts
3. Then run the Python script to generate files: python generate_all_files.py
4. Run: flutter pub get
5. Run: flutter run
```

### Option 2: Manual Setup

#### Step 1: Verify Flutter Installation
```bash
flutter doctor
```

#### Step 2: Create Project Structure
Run one of these commands in PowerShell:

```powershell
# PowerShell (run in PROJECT directory)
$dirs = @(
    "lib\core\theme",
    "lib\core\router", 
    "lib\core\utils",
    "lib\features\auth\presentation\screens",
    "lib\features\auth\presentation\providers",
    "lib\features\auth\domain\models",
    "lib\features\auth\data",
    "lib\features\chat\presentation\screens",
    "lib\features\chat\presentation\providers",
    "lib\features\chat\presentation\widgets",
    "lib\features\chat\domain\models",
    "lib\features\chat\data",
    "lib\shared\widgets"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host "✓ Directory structure created!" -ForegroundColor Green
```

#### Step 3: Run the File Generator
```bash
python generate_all_files.py
```

#### Step 4: Install Dependencies
```bash
flutter pub get
```

#### Step 5: Run the App
```bash
# For Chrome/Edge (web)
flutter run -d chrome

# For Android emulator
flutter run -d android

# For iOS simulator (Mac only)
flutter run -d ios
```

## Project Structure

```
chatgpt_clone/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── router/
│   │       └── app_router.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── landing_screen.dart
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   └── signup_screen.dart
│   │   │   │   └── providers/
│   │   │   │       └── auth_provider.dart
│   │   │   └── domain/
│   │   │       └── models/
│   │   │           └── user.dart
│   │   └── chat/
│   │       ├── presentation/
│   │       │   ├── screens/
│   │       │   │   ├── home_screen.dart
│   │       │   │   └── chat_screen.dart
│   │       │   ├── providers/
│   │       │   │   ├── chat_list_provider.dart
│   │       │   │   └── chat_provider.dart
│   │       │   └── widgets/
│   │       │       ├── chat_bubble.dart
│   │       │       └── chat_input.dart
│   │       └── domain/
│   │           └── models/
│   │               ├── chat.dart
│   │               └── message.dart
│   └── shared/
│       └── widgets/
│           └── custom_button.dart
├── pubspec.yaml
└── README.md
```

## Features

✅ **Authentication Flow**
- Landing screen with login/signup options
- Login screen with email/password validation
- Signup screen with form validation
- No actual backend (UI demonstration)

✅ **Chat Interface**
- Home screen with list of conversations
- Individual chat screens
- Message bubbles (user vs assistant)
- Auto-scroll to latest message
- Mock assistant responses with delay

✅ **UI/UX**
- Material Design 3
- Light and dark theme support
- Clean, minimal ChatGPT-inspired design
- Responsive layout
- Smooth animations

✅ **Architecture**
- Clean Architecture (feature-based)
- Riverpod for state management
- go_router for navigation
- Prepared for Dio integration (future backend)

## Testing the App

### Test Credentials (No actual validation)
- Email: any@email.com
- Password: anything (minimum 6 characters)

### App Flow
1. Launch app → Landing Screen
2. Click "Log in" or "Sign up"
3. Enter any email/password
4. Navigate to Home Screen (chat list)
5. Click "+" to create new chat
6. Send messages and see mock responses

## Troubleshooting

### "Flutter not found"
Install Flutter: https://docs.flutter.dev/get-started/install

### "No devices found"
- For Web: `flutter run -d chrome`
- For Android: Start an emulator first
- For iOS: Start simulator (Mac only)

### "Package not found"
Run: `flutter pub get`

### "Build failed"
1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Run: `flutter run`

## Dependencies

```yaml
flutter_riverpod: ^2.4.9  # State management
go_router: ^13.0.0        # Navigation
dio: ^5.4.0               # HTTP client (prepared)
image_picker: ^1.0.7      # Image selection
uuid: ^4.2.2              # Unique IDs
intl: ^0.19.0             # Date formatting
```

## Next Steps (Future Enhancements)

- [ ] Connect to actual ChatGPT API
- [ ] Add persistent storage (SQLite/Hive)
- [ ] Implement chat deletion
- [ ] Add chat search functionality
- [ ] Support for image messages
- [ ] Voice input integration
- [ ] Chat history export
- [ ] User preferences/settings
- [ ] Multiple chat models selection

## License

MIT License - Feel free to use this as a learning resource or starting point for your own projects.
