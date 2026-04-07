#!/bin/bash

echo "========================================"
echo "Flutter ChatGPT Clone - File Generator"
echo "========================================"
echo ""

# Create directory structure
echo "Creating directory structure..."

mkdir -p lib/core/theme
mkdir -p lib/core/router
mkdir -p lib/core/utils
mkdir -p lib/features/auth/presentation/screens
mkdir -p lib/features/auth/presentation/providers
mkdir -p lib/features/auth/domain/models
mkdir -p lib/features/auth/data
mkdir -p lib/features/chat/presentation/screens
mkdir -p lib/features/chat/presentation/providers
mkdir -p lib/features/chat/presentation/widgets
mkdir -p lib/features/chat/domain/models
mkdir -p lib/features/chat/data
mkdir -p lib/shared/widgets
mkdir -p android/app/src/main
mkdir -p ios/Runner
mkdir -p test
mkdir -p web

echo "✓ Directory structure created"
echo ""
echo "Now creating all Dart files..."
echo ""

# Now I'll create each file with a heredoc
echo "Creating lib/main.dart..."
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
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
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'ChatGPT Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
EOF

echo "✓ Created lib/main.dart"

echo ""
echo "========================================" 
echo "Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter run"
echo ""
