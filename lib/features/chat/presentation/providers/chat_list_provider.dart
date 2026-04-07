import 'package:flutter_riverpod/flutter_riverpod.dart';
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
