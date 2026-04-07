import os

# Continuation of file generation - Part 2
files = {
    'lib/features/chat/presentation/providers/chat_list_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';

const _uuid = Uuid();

class ChatListNotifier extends StateNotifier<List<Chat>> {
  ChatListNotifier() : super(_mockChats);

  static final List<Chat> _mockChats = [
    Chat(
      id: '1',
      title: 'Flutter Development',
      messages: [
        Message(
          id: '1',
          text: 'How do I create a custom widget in Flutter?',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          id: '2',
          text: 'To create a custom widget in Flutter, you can extend either StatelessWidget or StatefulWidget...',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Chat(
      id: '2',
      title: 'State Management',
      messages: [
        Message(
          id: '3',
          text: 'What are the differences between Provider and Riverpod?',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Message(
          id: '4',
          text: 'Riverpod is an evolution of Provider that addresses several limitations...',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Chat(
      id: '3',
      title: 'API Integration',
      messages: [
        Message(
          id: '5',
          text: 'How do I make HTTP requests in Flutter?',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Message(
          id: '6',
          text: 'You can use the http package or dio package for making HTTP requests...',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  void addChat(Chat chat) {
    state = [chat, ...state];
  }

  void updateChat(Chat updatedChat) {
    state = [
      for (final chat in state)
        if (chat.id == updatedChat.id) updatedChat else chat,
    ];
  }

  void deleteChat(String chatId) {
    state = state.where((chat) => chat.id != chatId).toList();
  }

  Chat? getChatById(String id) {
    try {
      return state.firstWhere((chat) => chat.id == id);
    } catch (e) {
      return null;
    }
  }

  String createNewChat() {
    final newChatId = _uuid.v4();
    final newChat = Chat(
      id: newChatId,
      title: 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
    );
    addChat(newChat);
    return newChatId;
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, List<Chat>>((ref) {
  return ChatListNotifier();
});
''',

    'lib/features/chat/presentation/providers/chat_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import 'chat_list_provider.dart';

const _uuid = Uuid();

final chatProvider = Provider.family<Chat?, String>((ref, chatId) {
  final chats = ref.watch(chatListProvider);
  try {
    return chats.firstWhere((chat) => chat.id == chatId);
  } catch (e) {
    return null;
  }
});

class ChatNotifier {
  ChatNotifier(this.ref, this.chatId);

  final Ref ref;
  final String chatId;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final chatListNotifier = ref.read(chatListProvider.notifier);
    final currentChat = chatListNotifier.getChatById(chatId);
    
    if (currentChat == null) return;

    final userMessage = Message(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentChat.messages, userMessage];
    
    String title = currentChat.title;
    if (currentChat.messages.isEmpty) {
      title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
    }

    chatListNotifier.updateChat(
      currentChat.copyWith(
        messages: updatedMessages,
        title: title,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    final assistantMessage = Message(
      id: _uuid.v4(),
      text: _generateAssistantResponse(text),
      isUser: false,
      timestamp: DateTime.now(),
    );

    final finalChat = chatListNotifier.getChatById(chatId);
    if (finalChat != null) {
      chatListNotifier.updateChat(
        finalChat.copyWith(
          messages: [...finalChat.messages, assistantMessage],
        ),
      );
    }
  }

  String _generateAssistantResponse(String userMessage) {
    final responses = [
      "That's an interesting question! Let me help you with that.",
      "I understand what you're asking. Here's what I think...",
      "Great question! Based on my knowledge, I can tell you that...",
      "Thanks for asking! Let me break this down for you.",
      "I'd be happy to help with that. Here's my response...",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }
}

final chatNotifierProvider = Provider.family<ChatNotifier, String>((ref, chatId) {
  return ChatNotifier(ref, chatId);
});
''',

    'lib/features/chat/presentation/screens/home_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_list_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final chatId = ref.read(chatListProvider.notifier).createNewChat();
              context.push('/chat/$chatId');
            },
          ),
        ],
      ),
      body: chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.chat,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    chat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(chat.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  onTap: () => context.push('/chat/${chat.id}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final chatId = ref.read(chatListProvider.notifier).createNewChat();
          context.push('/chat/$chatId');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''',

    'lib/features/chat/presentation/screens/chat_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider(widget.chatId));
    final chatNotifier = ref.read(chatNotifierProvider(widget.chatId));

    if (chat == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: const Center(
          child: Text('Chat not found'),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final message = chat.messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          ChatInput(
            onSend: (text) async {
              await chatNotifier.sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}
''',

    'lib/features/chat/presentation/widgets/chat_bubble.dart': '''import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
''',

    'lib/features/chat/presentation/widgets/chat_input.dart': '''import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  final Future<void> Function(String) onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final text = _controller.text;
    _controller.clear();
    
    setState(() => _isLoading = true);
    
    await widget.onSend(text);
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image selected: ${image.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _isLoading ? null : _pickImage,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _isLoading ? null : _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
''',

    'lib/shared/widgets/custom_button.dart': '''import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
''',
}

print("Continuing file generation (Part 2)...")
print("=" * 50)

for filepath, content in files.items():
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✓ Created {filepath}")

print("=" * 50)
print(f"✓ Generated {len(files)} additional files!")
print("\n" + "=" * 50)
print("ALL FILES GENERATED SUCCESSFULLY!")
print("=" * 50)
print("\nNext steps:")
print("1. Run: flutter pub get")
print("2. Run: flutter run -d chrome")
print("   (or replace 'chrome' with your device)")
print("\nProject is ready to run!")
