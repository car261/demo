import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chatgpt_clone/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:chatgpt_clone/features/auth/presentation/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  final String? currentChatId;

  const AppDrawer({super.key, this.currentChatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF212121) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with New Chat button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newChatId = ref.read(chatListProvider.notifier).createNewChat();
                    context.go('/chat/$newChatId');
                    Navigator.pop(context); // Close drawer
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Chat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Chat History
            Expanded(
              child: chats.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No chats yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final isSelected = chat.id == currentChatId;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2D2D2D) : Colors.grey[200])
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.grey[600],
                            ),
                            title: Text(
                              chat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark ? Colors.grey[400] : Colors.grey[800]),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                ref.read(chatListProvider.notifier).deleteChat(chat.id);
                                if (chat.id == currentChatId) {
                                  // If deleting current chat, create and navigate to new chat
                                  final newChatId = ref.read(chatListProvider.notifier).createNewChat();
                                  context.go('/chat/$newChatId');
                                }
                                Navigator.pop(context);
                              },
                            ),
                            onTap: () {
                              if (chat.id != currentChatId) {
                                context.go('/chat/${chat.id}');
                              }
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 1),

            // Settings & Profile Section
            ListTile(
              leading: const Icon(Icons.settings_outlined, size: 22),
              title: const Text('Settings', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings - Coming soon')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline, size: 22),
              title: const Text('Profile', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile - Coming soon')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout_outlined, size: 22),
              title: const Text('Logout', style: TextStyle(fontSize: 14)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/');
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
