import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';
import 'package:chatgpt_clone/features/auth/presentation/providers/auth_provider.dart';
import 'package:chatgpt_clone/features/chat/domain/models/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/models/message.dart';

const _uuid = Uuid();

class ChatListNotifier extends StateNotifier<List<Chat>> {
  ChatListNotifier(this.ref) : super(_mockChats);

  final Ref ref;
  final ApiService _apiService = ApiService();

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

  void clearChats() {
    state = [];
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

  Future<void> sendMessage(String chatId, String userMessage) async {
    final chat = getChatById(chatId);
    if (chat == null) return;

    try {
      // Call API with correct endpoint
      final token = ref.read(authProvider).token;
      final response = await _apiService.post(
        '/api/chat',
        data: {'message': userMessage},
        token: token,
      );

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200) {
        // Parse response according to standard format
        final responseData = data?['data'] as Map<String, dynamic>?;
        final aiResponse = (responseData?['assistant'] ?? responseData?['reply']) as String?;
        
        if (aiResponse != null && aiResponse.isNotEmpty) {
          // Add AI message
          final aiMsg = Message(
            id: _uuid.v4(),
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          );

          final finalChat = getChatById(chatId);
          if (finalChat != null) {
            updateChat(
              finalChat.copyWith(
                messages: [...finalChat.messages, aiMsg],
              ),
            );
          }
        } else {
          _addErrorMessage(chatId, 'No response received');
        }
      } else {
        // Handle error response
        final message = data?['message'] as String?;
        _addErrorMessage(chatId, message ?? 'Failed to get response');
      }
    } catch (e) {
      _addErrorMessage(chatId, 'Network error: ${e.toString()}');
    }
  }

  Future<void> loadHistory() async {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await _apiService.get(
        '/api/history',
        token: token,
      );

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = null;
      }

      if (response.statusCode != 200) {
        return;
      }

      final responseData = data?['data'] as Map<String, dynamic>?;
      final rawMessages = responseData?['messages'] ?? responseData?['chats'];
      if (rawMessages is! List) {
        return;
      }

      final messages = <Message>[];
      for (final item in rawMessages) {
        if (item is! Map) continue;

        final text = item['message'] as String?;
        final isUser = item['is_user'] == true || item['is_user'] == 1;
        final rawTimestamp = item['timestamp'] as String?;
        final parsed = rawTimestamp != null ? DateTime.tryParse(rawTimestamp) : null;

        if (text == null || text.isEmpty) continue;

        messages.add(
          Message(
            id: _uuid.v4(),
            text: text,
            isUser: isUser,
            timestamp: parsed ?? DateTime.now(),
          ),
        );
      }

      if (messages.isEmpty) {
        return;
      }

      final createdAt = messages.first.timestamp;
      final historyChat = Chat(
        id: 'history',
        title: 'Chat History',
        messages: messages,
        createdAt: createdAt,
      );

      state = [historyChat];
    } catch (_) {
      return;
    }
  }

  void _addErrorMessage(String chatId, String errorText) {
    final finalChat = getChatById(chatId);
    if (finalChat != null) {
      final errorMsg = Message(
        id: _uuid.v4(),
        text: 'Error: $errorText',
        isUser: false,
        timestamp: DateTime.now(),
      );

      updateChat(
        finalChat.copyWith(
          messages: [...finalChat.messages, errorMsg],
        ),
      );
    }
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, List<Chat>>((ref) {
  return ChatListNotifier(ref);
});
