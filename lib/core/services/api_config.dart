class ApiConfig {
  // Base URL for Android Emulator (host machine gateway).
  static const String baseUrl = "http://10.0.2.2:5000";

  // Override base URL if needed (e.g., real device IP).
  static const String customBaseUrl = ""; // Leave empty to use baseUrl
  
  static String getBaseUrl() {
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }
    return baseUrl;
  }
}