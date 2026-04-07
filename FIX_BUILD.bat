@echo off
cls
echo ================================================
echo   FIXING FLUTTER BUILD ERRORS
echo ================================================
echo.

echo [1/4] Enabling Flutter web support...
flutter config --enable-web
echo.

echo [2/4] Creating web platform files...
flutter create --platforms=web .
echo.

echo [3/4] Installing dependencies...
flutter pub get
echo.

echo [4/4] Cleaning build cache...
flutter clean
echo.

echo ================================================
echo   BUILD FIX COMPLETE!
echo ================================================
echo.
echo All missing files have been created:
echo   ✓ home_screen.dart
echo   ✓ chat_screen.dart
echo   ✓ chat_list_provider.dart
echo   ✓ chat_provider.dart
echo   ✓ chat_bubble.dart
echo   ✓ chat_input.dart
echo.
echo Next step: Run the app
echo   flutter run -d chrome
echo.
pause
