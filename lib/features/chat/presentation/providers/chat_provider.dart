import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    await Future.delayed(const Duration(milliseconds: 1500));

    final assistantMessage = Message(
      id: _uuid.v4(),
      text: _generateFoodAnalysisResponse(),
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

  String _generateFoodAnalysisResponse() {
    final foodItems = [
      'pizza',
      'burger',
      'salad',
      'pasta',
      'sushi',
      'sandwich',
      'soup',
      'steak',
      'chicken',
      'fish',
      'rice bowl',
      'noodles',
      'tacos',
      'curry',
      'wrap',
    ];
    
    final calories = [250, 350, 450, 550, 650, 750, 850];
    
    final selectedFood = foodItems[DateTime.now().millisecond % foodItems.length];
    final selectedCalories = calories[DateTime.now().second % calories.length];
    
    final responses = [
      "This looks like $selectedFood! 🍽️\n\nEstimated calories: ~$selectedCalories kcal\n\nNutritional highlights:\n• Good source of protein\n• Contains essential vitamins\n• Moderate carbohydrates\n\nWould you like more detailed nutritional information?",
      "I can see $selectedFood in your image! 😋\n\nCalorie estimate: $selectedCalories kcal\n\nThis meal appears to be:\n• Balanced in macronutrients\n• Rich in flavor\n• A satisfying portion\n\nNeed cooking tips or recipes?",
      "That's a delicious-looking $selectedFood! 🌟\n\nApproximate calories: $selectedCalories kcal\n\nHealth notes:\n• Provides good energy\n• Contains important nutrients\n• Part of a balanced diet\n\nShall I suggest similar healthy alternatives?",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }
}

final chatNotifierProvider = Provider.family<ChatNotifier, String>((ref, chatId) {
  return ChatNotifier(ref, chatId);
});
