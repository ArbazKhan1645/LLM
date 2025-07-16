import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:llm_video_shopify/app/services/chat_service/chat_service.dart';

// Chat Controller - Enterprise-level state management
class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AIChatService _apiService =
      Get.find<AIChatService>(); // Get the API service instance

  // Chat state
  final RxBool isTyping = false.obs;
  final RxBool isSending = false.obs;
  final RxString typingText = ''.obs;
  final RxBool isAssistantTyping = false.obs;

  // UI state
  final RxBool showScrollToBottom = false.obs;
  Timer? _typingTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    _setupScrollListener();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }

  void _initializeChat() {
    // Add initial assistant message
    messages.add(
      ChatMessage(
        id: '1',
        text: "Hi there! I'm your AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        avatar: 'assets/assistant_avatar.png',
      ),
    );
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final isAtBottom =
          scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100;
      showScrollToBottom.value = !isAtBottom;
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    messageController.clear();
    isSending.value = true;

    // Haptic feedback
    HapticFeedback.lightImpact();
    _scrollToBottom();

    try {
      // Show typing indicator
      isAssistantTyping.value = true;

      // Get AI response
      final response = await _apiService.sendMessage(message: text);

      // Add AI response
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        avatar: 'assets/assistant_avatar.png',
      );

      messages.add(assistantMessage);
      _scrollToBottom();
    } catch (e) {
      // Show error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Sorry, I couldn't process your request. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
        avatar: 'assets/assistant_avatar.png',
      );

      messages.add(errorMessage);
      _scrollToBottom();

      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
      isAssistantTyping.value = false;
    }
  }

  void onMessageChanged(String text) {
    if (text.isEmpty) {
      isTyping.value = false;
      _typingTimer?.cancel();
    } else {
      if (!isTyping.value) {
        isTyping.value = true;
      }

      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        isTyping.value = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToBottom() {
    _scrollToBottom();
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? avatar;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.avatar,
  });
}
