import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/conversation_model.dart';
import 'dart:async';

class ChatListController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  late TabController tabController;
  final conversations = <ConversationModel>[].obs;
  final isLoading = false.obs;
  StreamSubscription? _conversationsSubscription;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _listenToConversations();
  }

  void _listenToConversations() {
    isLoading.value = true;
    _conversationsSubscription = _chatRepository.streamConversations().listen(
      (convList) {
        conversations.value = convList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        // Suppress error as per user request
        print('Error loading conversations: $error');
      },
    );
  }

  Future<void> refreshConversations() async {
    // For manual refresh, we can just re-subscribe or the stream will handle it
    _conversationsSubscription?.cancel();
    _listenToConversations();
  }

  void openChat(String conversationId) {
    Get.toNamed('/chat-detail', arguments: {'conversationId': conversationId});
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    tabController.dispose();
    super.onClose();
  }
}
