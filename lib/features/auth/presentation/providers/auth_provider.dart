import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

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
    
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: '1',
      name: 'User',
      email: email,
    );
    
    state = state.copyWith(user: user, isLoading: false);
    return true;
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
    
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: '1',
      name: name,
      email: email,
    );
    
    state = state.copyWith(user: user, isLoading: false);
    return true;
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
