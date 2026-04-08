import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chatgpt_clone/features/auth/presentation/screens/landing_screen.dart';
import 'package:chatgpt_clone/features/auth/presentation/screens/login_screen.dart';
import 'package:chatgpt_clone/features/auth/presentation/screens/signup_screen.dart';
import 'package:chatgpt_clone/features/chat/presentation/screens/home_screen.dart';
import 'package:chatgpt_clone/features/chat/presentation/screens/chat_screen.dart';
import 'package:chatgpt_clone/features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    observers: [RouteLoggingObserver()],
    redirect: (context, state) {
      if (!authState.isInitialized) {
        return null;
      }

      final hasToken = authState.token != null && authState.token!.isNotEmpty;
      final location = state.uri.toString();

      if (hasToken && (location == '/' || location == '/login' || location == '/signup')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          debugPrint('Route loaded: /');
          return const LandingScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          debugPrint('Route loaded: /login');
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          debugPrint('Route loaded: /signup');
          return const SignupScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          debugPrint('Route loaded: /home');
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          debugPrint('Route loaded: /chat/$chatId');
          return ChatScreen(chatId: chatId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('Router error: ${state.error}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('App Running'),
              const SizedBox(height: 12),
              Text(
                'Routing error. Showing fallback UI.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to start'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

class RouteLoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Navigator push: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Navigator pop: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }
}
