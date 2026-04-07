import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  SharedPreferences? _prefs;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:5000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // Do NOT force Content-Type here; let Dio
        // set it automatically only when needed.
      ),
    );

    // Interceptor reads the JWT token from the in-memory field.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _jwtToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Load token from SharedPreferences asynchronously.
    _loadToken();
  }

  String? _jwtToken;

  Future<void> _loadToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    _jwtToken = _prefs!.getString('access_token');
  }

  String? get token => _jwtToken;

  void setToken(String token) {
    _jwtToken = token;
    _prefs?.setString('access_token', token);
  }

  void clearToken() {
    _jwtToken = null;
    _prefs?.remove('access_token');
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}