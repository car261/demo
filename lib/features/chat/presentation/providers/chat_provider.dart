import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';
import 'package:chatgpt_clone/features/chat/domain/models/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/models/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/providers/chat_list_provider.dart';

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
  ChatNotifier(this.ref, this.chatId) : _apiService = ApiService();

  final Ref ref;
  final String chatId;
  final ApiService _apiService;

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

    // Use API instead of mock
    await chatListNotifier.sendMessage(chatId, text);
  }

  Future<void> sendImageMessage(String imagePath) async {
    final chatListNotifier = ref.read(chatListProvider.notifier);
    final currentChat = chatListNotifier.getChatById(chatId);
    
    if (currentChat == null) return;

    final userMessage = Message(
      id: _uuid.v4(),
      imagePath: imagePath,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentChat.messages, userMessage];
    
    String title = currentChat.title;
    if (currentChat.messages.isEmpty) {
      title = 'Food Image';
    }

    chatListNotifier.updateChat(
      currentChat.copyWith(
        messages: updatedMessages,
        title: title,
      ),
    );

    // Call backend /predict with the selected image
    String analysisText;
    try {
      final response = await _apiService.postMultipart(
        '/predict',
        filePath: imagePath,
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
        final dynamic rawIngredients = data?['ingredients'];
        final ingredients = rawIngredients is List
            ? rawIngredients.whereType<String>().toList()
            : <String>[];

        if (ingredients.isEmpty) {
          analysisText = 'No ingredients detected.';
        } else {
          analysisText = 'Ingredients: ${ingredients.join(', ')}';
        }
      } else {
        final dynamic rawError = data?['error'];
        final errorText = rawError is String && rawError.isNotEmpty
            ? rawError
            : 'Unknown error';
        analysisText = 'Prediction failed: $errorText';
      }
    } catch (e) {
      analysisText = 'Network error during prediction: ${e.toString()}';
    }

    final assistantMessage = Message(
      id: _uuid.v4(),
      text: analysisText,
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
}

final chatNotifierProvider = Provider.family<ChatNotifier, String>((ref, chatId) {
  return ChatNotifier(ref, chatId);
});
