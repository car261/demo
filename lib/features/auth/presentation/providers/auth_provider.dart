import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String? token;
  final bool isInitialized;

  AuthState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.token,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    String? token,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      token: token ?? this.token,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(AuthState());

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  bool _isRequestSuccess(int statusCode, Map<String, dynamic> body) {
    final status = (body['status'] ?? '').toString().toLowerCase();
    final validStatusCode = statusCode == 200 || statusCode == 201;
    return validStatusCode && status == 'success';
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    state = state.copyWith(
      token: token,
      isInitialized: true,
      error: null,
      successMessage: null,
    );
  }

  Future<void> _persistToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', token);
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _apiService.post(
        "/api/auth/signup",
        data: {
          "name": name,
          "email": email,
          "password": password,
        },
      );

      final body = _decodeBody(response.body);
      final message = (body['message'] ?? 'Signup completed').toString();
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (_isRequestSuccess(response.statusCode, body)) {
        final token = (data['token'] ?? '').toString();
        state = state.copyWith(
          isLoading: false,
          token: token.isEmpty ? null : token,
          isInitialized: true,
          error: null,
          successMessage: message,
        );
        if (token.isNotEmpty) {
          await _persistToken(token);
        }
        return true;
      }

      state = state.copyWith(isLoading: false, error: message, successMessage: null);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Network error: $e",
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final response = await _apiService.post(
        "/api/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      final body = _decodeBody(response.body);
      final message = (body['message'] ?? 'Login completed').toString();
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (_isRequestSuccess(response.statusCode, body)) {
        final token = (data['access_token'] ?? data['token'] ?? '').toString();
        state = state.copyWith(
          isLoading: false,
          token: token.isEmpty ? null : token,
          isInitialized: true,
          error: null,
          successMessage: message,
        );
        if (token.isNotEmpty) {
          await _persistToken(token);
        }
        return true;
      }

      state = state.copyWith(isLoading: false, error: message, successMessage: null);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Network error: $e",
      );
      return false;
    }
  }

  void logout() {
    _persistToken(null);
    state = AuthState(isInitialized: true);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});