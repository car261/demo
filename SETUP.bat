@echo off
echo ========================================
echo Flutter ChatGPT Clone Setup
echo ========================================
echo.

REM Step 1: Check Flutter
echo [1/4] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)
echo.

REM Step 2: Create Flutter project
echo [2/4] Creating Flutter project...
flutter create --org com.chatgpt --project-name chatgpt_clone .
echo.

REM Step 3: Update pubspec.yaml
echo [3/4] Updating dependencies...
echo NOTE: pubspec.yaml has been created. You need to replace it with the provided one.
pause

REM Step 4: Get dependencies
echo [4/4] Getting Flutter packages...
flutter pub get
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Copy all Dart files from ALL_DART_FILES.txt to their respective locations
echo 2. Run: flutter pub get (if not done)
echo 3. Run: flutter run
echo.
pause
