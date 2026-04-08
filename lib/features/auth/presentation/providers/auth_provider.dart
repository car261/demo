import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;

  AuthState({this.isLoading = false, this.error, this.token});

  AuthState copyWith({bool? isLoading, String? error, String? token}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(AuthState());

  Future<bool> signup(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        "/api/auth/signup",
        data: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 201) {
        // Parse response
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final data = decoded['data'] as Map<String, dynamic>?;
            if (data != null) {
              state = state.copyWith(
                isLoading: false,
                token: data['token'],
              );
              return true;
            }
          }
        } catch (_) {}
        
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        // Parse error response
        try {
          final decoded = jsonDecode(response.body);
          final message = decoded['message'] ?? 'Signup failed';
          state = state.copyWith(isLoading: false, error: message);
        } catch (_) {
          state = state.copyWith(isLoading: false, error: "Signup failed");
        }
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Network error: $e",
      );
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        "/api/auth/login",
        data: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        // Parse response
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final data = decoded['data'] as Map<String, dynamic>?;
            if (data != null) {
              final token = data['access_token'] ?? data['token'];
              state = state.copyWith(
                isLoading: false,
                token: token,
              );
              return true;
            }
          }
        } catch (_) {}
        
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        // Parse error response
        try {
          final decoded = jsonDecode(response.body);
          final message = decoded['message'] ?? 'Login failed';
          state = state.copyWith(isLoading: false, error: message);
        } catch (_) {
          state = state.copyWith(isLoading: false, error: "Login failed");
        }
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Network error: $e",
      );
      return false;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});