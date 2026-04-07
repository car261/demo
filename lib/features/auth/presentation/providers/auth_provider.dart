import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';
import '../../domain/models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? token;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.token,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    String? token,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(AuthState()) {
    _loadSavedToken();
  }

  Future<void> _loadSavedToken() async {
    // Wait a bit for token to load
    await Future.delayed(const Duration(milliseconds: 100));
    final token = _apiService.token;
    if (token != null) {
      // Optionally, validate token or load user
      state = state.copyWith(token: token);
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return false;
    }

    if (!email.contains('@')) {
      state = state.copyWith(error: 'Please enter a valid email');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/login', data: {
        'username': email,  // Backend expects 'username', but we're using email
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        _apiService.setToken(token);
        
        final user = User(
          id: '1',  // Could parse from token or response
          name: email.split('@')[0],  // Simple name from email
          email: email,
        );
        
        state = state.copyWith(user: user, token: token, isLoading: false);
        return true;
      } else {
        state = state.copyWith(error: response.data['msg'] ?? 'Login failed', isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}', isLoading: false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return false;
    }

    if (!email.contains('@')) {
      state = state.copyWith(error: 'Please enter a valid email');
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/register', data: {
        'username': email,  // Backend expects 'username'
        'password': password,
      });

      if (response.statusCode == 201) {
        // After signup, auto-login
        return await login(email, password);
      } else {
        state = state.copyWith(error: response.data['msg'] ?? 'Signup failed', isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}', isLoading: false);
      return false;
    }
  }

  void logout() {
    _apiService.clearToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
