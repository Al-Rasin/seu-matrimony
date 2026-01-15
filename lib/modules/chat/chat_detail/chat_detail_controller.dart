import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../core/services/storage_service.dart';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final messageController = TextEditingController();
  final messages = <Map<String, dynamic>>[].obs;
  final recipientName = ''.obs;
  final isLoading = false.obs;

  String? conversationId;
  String get currentUserId => _storageService.userId ?? '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    conversationId = args?['conversationId'];
    if (conversationId != null) {
      loadMessages();
    }
  }

  Future<void> loadMessages() async {
    if (conversationId == null) return;

    try {
      isLoading.value = true;
      final response = await _chatRepository.getMessages(conversationId!);
      messages.value = List<Map<String, dynamic>>.from(response['data'] ?? []);

      final conversation = await _chatRepository.getConversation(conversationId!);
      recipientName.value = conversation['recipientName'] ?? 'Unknown';
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (conversationId == null || messageController.text.trim().isEmpty) return;

    try {
      final content = messageController.text.trim();
      messageController.clear();

      await _chatRepository.sendMessage(conversationId!, content);
      loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  void initiateVideoCall() {
    Get.snackbar('Coming Soon', 'Video calling feature coming soon');
  }

  void initiateVoiceCall() {
    Get.snackbar('Coming Soon', 'Voice calling feature coming soon');
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
