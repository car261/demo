@echo off
cls
echo.
echo ================================================
echo    Flutter ChatGPT Clone - Complete Setup
echo ================================================
echo.

REM Step 1: Generate all project files
echo [Step 1/3] Generating project files...
echo.
python generate_all_files.py
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate files (Part 1)
    pause
    exit /b 1
)

python generate_all_files_part2.py
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate files (Part 2)
    pause
    exit /b 1
)

echo.
echo ================================================
echo.

REM Step 2: Install Flutter dependencies
echo [Step 2/3] Installing Flutter packages...
echo.
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    echo Make sure Flutter is installed and in your PATH
    pause
    exit /b 1
)

echo.
echo ================================================
echo.

REM Step 3: Success message
echo [Step 3/3] Setup Complete!
echo.
echo ================================================
echo    ✓ Project setup successful!
echo ================================================
echo.
echo Your ChatGPT Clone is ready to run!
echo.
echo To run the app:
echo   • Web (Chrome):    flutter run -d chrome
echo   • Android:         flutter run -d android
echo   • iOS (Mac only):  flutter run -d ios
echo.
echo Project Features:
echo   ✓ Landing Screen with Auth Options
echo   ✓ Login/Signup Screens
echo   ✓ Home Screen with Chat List
echo   ✓ Chat Interface with Messages
echo   ✓ Mock AI Responses
echo   ✓ Image Picker Integration
echo   ✓ Light/Dark Theme Support
echo.
echo ================================================
echo.
pause
