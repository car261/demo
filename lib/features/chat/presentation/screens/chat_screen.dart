import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatgpt_clone/features/chat/presentation/providers/chat_provider.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/chat_input.dart';
import 'package:chatgpt_clone/shared/widgets/app_drawer.dart';

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
        drawer: AppDrawer(currentChatId: widget.chatId),
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
      drawer: AppDrawer(currentChatId: widget.chatId),
      appBar: AppBar(
        title: Text(chat.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Add more options
            },
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
            onImageSend: (imagePath) async {
              await chatNotifier.sendImageMessage(imagePath);
            },
          ),
        ],
      ),
    );
  }
}
