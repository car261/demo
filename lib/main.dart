import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/chat/presentation/providers/chat_list_provider.dart';

void main() {
  debugPrint('App starting...');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isInitialized) {
      ref.read(authProvider.notifier).initialize();
    }

    ref.listen<AuthState>(authProvider, (previous, next) {
      final previousToken = previous?.token;
      final currentToken = next.token;

      if (currentToken != null && currentToken.isNotEmpty && currentToken != previousToken) {
        ref.read(chatListProvider.notifier).loadHistory();
      }
    });

    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Food Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) {
          return const Scaffold(
            body: Center(
              child: Text('App Running'),
            ),
          );
        }
        return child;
      },
    );
  }
}
