@echo off
echo Enabling Flutter web support...
flutter config --enable-web
echo.
echo Web support enabled!
echo.
echo Now creating web files...
flutter create --platforms=web .
echo.
echo Done! Now run: flutter pub get
pause
