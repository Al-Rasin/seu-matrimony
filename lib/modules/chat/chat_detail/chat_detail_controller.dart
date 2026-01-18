import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/conversation_model.dart';
import 'dart:async';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final messageController = TextEditingController();
  final messages = <MessageModel>[].obs;
  final conversation = Rxn<ConversationModel>();
  final isLoading = false.obs;
  final isOtherTyping = false.obs;
  
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  String? conversationId;
  String get currentUserId => _authService.currentUserId ?? '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    conversationId = args?['conversationId'];
    if (conversationId != null) {
      _loadConversationDetails();
      _listenToMessages();
      _listenToTypingStatus();
      _markAsRead();
    }
  }

  void onTextChanged(String value) {
    if (conversationId == null) return;
    
    // Set typing status to true
    _chatRepository.setTypingStatus(conversationId!, true);
    
    // Reset timer to set typing status to false after 3 seconds of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _chatRepository.setTypingStatus(conversationId!, false);
    });
  }

  void _listenToTypingStatus() {
    if (conversationId == null) return;
    
    _typingSubscription = _chatRepository.streamTypingStatus(conversationId!).listen((typingMap) {
      final otherId = conversation.value?.getOtherParticipantId(currentUserId);
      if (otherId != null && otherId.isNotEmpty) {
        final lastTyped = typingMap[otherId];
        if (lastTyped != null) {
          // If Firestore timestamp is recent (within last 5 seconds)
          DateTime typedAt;
          if (lastTyped is Timestamp) {
            typedAt = lastTyped.toDate();
          } else {
            typedAt = DateTime.now().subtract(const Duration(seconds: 10));
          }
          
          isOtherTyping.value = DateTime.now().difference(typedAt).inSeconds < 5;
        } else {
          isOtherTyping.value = false;
        }
      }
    });
  }

  Future<void> _loadConversationDetails() async {
    try {
      final response = await _chatRepository.getConversation(conversationId!);
      if (response['success']) {
        conversation.value = ConversationModel.fromFirestore(response['data']);
      }
    } catch (e) {
      debugPrint('Error loading conversation: $e');
    }
  }

  void _listenToMessages() {
    if (conversationId == null) return;
    
    isLoading.value = true;
    _messagesSubscription = _chatRepository.streamMessages(conversationId!).listen(
      (messageList) {
        messages.value = messageList;
        isLoading.value = false;
        _markAsRead(); // Mark as read when new messages arrive while in chat
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to load messages');
      },
    );
  }

  Future<void> _markAsRead() async {
    if (conversationId == null) return;
    await _chatRepository.markAsRead(conversationId!);
  }

  Future<void> sendMessage() async {
    if (conversationId == null || messageController.text.trim().isEmpty) return;

    try {
      final content = messageController.text.trim();
      messageController.clear();

      await _chatRepository.sendMessage(conversationId!, content);
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
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    // Clear typing status when leaving chat
    if (conversationId != null) {
      _chatRepository.setTypingStatus(conversationId!, false);
    }
    messageController.dispose();
    super.onClose();
  }
}
