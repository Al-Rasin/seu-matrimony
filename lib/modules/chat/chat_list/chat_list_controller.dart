import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatListController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  late TabController tabController;
  final conversations = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      final response = await _chatRepository.getConversations();
      conversations.value =
          List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void openChat(String conversationId) {
    Get.toNamed('/chat-detail', arguments: {'conversationId': conversationId});
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
