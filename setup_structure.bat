@echo off
echo Creating Flutter ChatGPT Clone Project Structure...
echo.

REM Create main directories
mkdir lib 2>nul
mkdir lib\core 2>nul
mkdir lib\core\theme 2>nul
mkdir lib\core\router 2>nul
mkdir lib\core\utils 2>nul

mkdir lib\features 2>nul
mkdir lib\features\auth 2>nul
mkdir lib\features\auth\presentation 2>nul
mkdir lib\features\auth\presentation\screens 2>nul
mkdir lib\features\auth\presentation\providers 2>nul
mkdir lib\features\auth\domain 2>nul
mkdir lib\features\auth\domain\models 2>nul
mkdir lib\features\auth\data 2>nul

mkdir lib\features\chat 2>nul
mkdir lib\features\chat\presentation 2>nul
mkdir lib\features\chat\presentation\screens 2>nul
mkdir lib\features\chat\presentation\providers 2>nul
mkdir lib\features\chat\presentation\widgets 2>nul
mkdir lib\features\chat\domain 2>nul
mkdir lib\features\chat\domain\models 2>nul
mkdir lib\features\chat\data 2>nul

mkdir lib\shared 2>nul
mkdir lib\shared\widgets 2>nul

mkdir android 2>nul
mkdir android\app 2>nul
mkdir android\app\src 2>nul
mkdir android\app\src\main 2>nul

mkdir ios 2>nul
mkdir ios\Runner 2>nul

mkdir test 2>nul
mkdir web 2>nul

echo.
echo ✓ Directory structure created successfully!
echo.
echo Next steps:
echo 1. Run the generate_files.bat script to create all Dart files
echo 2. Run: flutter pub get
echo 3. Run: flutter run
echo.
pause
