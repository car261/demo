import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:chatgpt_clone/core/services/api_service.dart';
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

    // Call backend placeholder for food analysis
    final analysisText = await _generateFoodAnalysisResponse();

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

  /// Placeholder that calls the backend /ask endpoint to simulate
  /// food image analysis. The actual image is not sent yet; only
  /// a descriptive query string is used.
  Future<String> _generateFoodAnalysisResponse() async {
    try {
      final response = await _apiService.post('/ask', data: {
        'query': 'Please provide a nutritional analysis for the food in the image.',
      });

      if (response.statusCode == 200) {
        return (response.data['response'] as String?) ??
            'Image analysis response not available.';
      }

      return 'Image analysis failed: \'${response.data['msg'] ?? 'Unknown error'}\'';
    } catch (e) {
      return 'Network error during image analysis: ${e.toString()}';
    }
  }
}

final chatNotifierProvider = Provider.family<ChatNotifier, String>((ref, chatId) {
  return ChatNotifier(ref, chatId);
});
