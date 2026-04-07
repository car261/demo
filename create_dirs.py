import os

# Create directory structure
dirs = [
    'lib/core/theme',
    'lib/core/router',
    'lib/core/utils',
    'lib/features/auth/presentation/screens',
    'lib/features/auth/presentation/providers',
    'lib/features/auth/domain/models',
    'lib/features/auth/data',
    'lib/features/chat/presentation/screens',
    'lib/features/chat/presentation/providers',
    'lib/features/chat/presentation/widgets',
    'lib/features/chat/domain/models',
    'lib/features/chat/data',
    'lib/shared/widgets',
    'android/app/src/main',
    'ios/Runner',
    'test',
    'web',
]

for d in dirs:
    os.makedirs(d, exist_ok=True)
    
print('✓ All directories created successfully')
