import 'dart:io';

class ApiConfig {
  // Determine base URL based on platform and environment
  // For Android Emulator: use 10.0.2.2 (host machine gateway)
  // For iOS Simulator: use localhost
  // For real devices: use your PC's local IP
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator special IP for host machine
      return "http://10.0.2.2:5000";
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return "http://localhost:5000";
    } else {
      // Web or desktop - use localhost
      return "http://localhost:5000";
    }
  }

  // Alternative for testing - override base URL if needed
  // Set this to your PC's actual IP (e.g., 192.168.1.100) for real device testing
  static const String customBaseUrl = ""; // Leave empty to auto-detect
  
  static String getBaseUrl() {
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }
    return baseUrl;
  }
}