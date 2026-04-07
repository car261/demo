# ChatGPT Clone - Flutter Mobile App

## Setup Instructions

### 1. Create Flutter Project Structure

First, create the directory structure by running these commands in your terminal:

```bash
cd C:\Users\HP\Desktop\PROJECT

# Create lib directories
mkdir -p lib\core\theme lib\core\router lib\core\utils
mkdir -p lib\features\auth\presentation\screens lib\features\auth\presentation\providers lib\features\auth\domain\models lib\features\auth\data
mkdir -p lib\features\chat\presentation\screens lib\features\chat\presentation\providers lib\features\chat\presentation\widgets lib\features\chat\domain\models lib\features\chat\data
mkdir -p lib\shared\widgets

# Create Flutter structure
mkdir -p android\app\src\main ios\Runner test web
```

Or run this PowerShell command:
```powershell
@("lib\core\theme", "lib\core\router", "lib\core\utils", "lib\features\auth\presentation\screens", "lib\features\auth\presentation\providers", "lib\features\auth\domain\models", "lib\features\auth\data", "lib\features\chat\presentation\screens", "lib\features\chat\presentation\providers", "lib\features\chat\presentation\widgets", "lib\features\chat\domain\models", "lib\features\chat\data", "lib\shared\widgets", "android\app\src\main", "ios\Runner", "test", "web") | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ }
```

### 2. Install Dependencies

After creating all the files, run:

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── landing_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── user.dart
│   │   └── data/
│   └── chat/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── home_screen.dart
│       │   │   └── chat_screen.dart
│       │   ├── providers/
│       │   │   ├── chat_list_provider.dart
│       │   │   └── chat_provider.dart
│       │   └── widgets/
│       │       ├── chat_bubble.dart
│       │       └── chat_input.dart
│       ├── domain/
│       │   └── models/
│       │       ├── chat.dart
│       │       └── message.dart
│       └── data/
├── shared/
│   └── widgets/
│       └── custom_button.dart
└── main.dart
```

## Features

✅ Landing Screen with Login/Signup
✅ Authentication UI (Login & Signup)
✅ Home Screen with Chat List
✅ Chat Screen with Message Interface
✅ New Chat Creation
✅ Mock Assistant Responses
✅ Image Picker Integration
✅ Light & Dark Theme Support
✅ Clean Architecture
✅ Riverpod State Management
✅ Go Router Navigation

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Clean Architecture (feature-based)
- **State Management**: Riverpod
- **Navigation**: go_router
- **Networking**: Dio (prepared for future backend)
- **Image Picker**: image_picker

## Notes

- All data is stored in memory (no persistence)
- Assistant responses are mocked with a delay
- Image picker is integrated but images are not processed
- No actual authentication backend (UI only)

