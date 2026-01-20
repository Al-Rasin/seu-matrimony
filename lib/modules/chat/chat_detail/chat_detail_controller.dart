import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/conversation_model.dart';
import 'dart:async';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

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
    debugPrint('ChatDetailController onInit args: $args');
    conversationId = args?['conversationId'];
    
    // Initialize with passed conversation object if available (for instant UI)
    if (args != null && args.containsKey('conversation')) {
      final passedConversation = args['conversation'];
      if (passedConversation is ConversationModel) {
        debugPrint('Initialized with passed conversation object');
        conversation.value = passedConversation;
      }
    }

    // Initialize with user details (from Profile page)
    if (args != null && args.containsKey('userId') && conversationId == null) {
      debugPrint('Initializing chat from profile with userId: ${args['userId']}');
      final userId = args['userId'];
      final userName = args['userName'] ?? 'Unknown';
      final userPhoto = args['userPhoto'];
      
      // Create temporary conversation object for UI
      conversation.value = ConversationModel(
        id: 'temp',
        participants: [currentUserId, userId],
        createdAt: DateTime.now(),
        participantId: userId,
        participantName: userName,
        participantPhoto: userPhoto,
        isOnline: false,
      );
      
      _initializeChatWithUser(userId);
    } else if (conversationId != null) {
      debugPrint('Loading existing conversation: $conversationId');
      _loadConversationDetails();
      _listenToMessages();
      _listenToTypingStatus();
      _markAsRead();
    } else {
      debugPrint('Error: No conversationId or userId provided');
    }
  }

  Future<void> _initializeChatWithUser(String otherUserId) async {
    try {
      debugPrint('Creating/Getting conversation for user: $otherUserId');
      isLoading.value = true;
      final response = await _chatRepository.createConversation(otherUserId);
      debugPrint('Create conversation response: $response');
      
      if (response['success']) {
        final data = response['data'];
        conversationId = data['id'];
        debugPrint('Conversation initialized with ID: $conversationId');
        
        // If it was an existing conversation, load its full details
        if (response['isExisting'] == true) {
          _loadConversationDetails();
        } 
        
        // Start listening
        _listenToMessages();
        _listenToTypingStatus();
      } else {
        Get.snackbar('Error', 'Failed to initialize chat');
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      Get.snackbar('Error', 'Failed to start conversation');
    } finally {
      isLoading.value = false;
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
      debugPrint('Loading conversation details for: $conversationId');
      final response = await _chatRepository.getConversation(conversationId!);
      if (response['success']) {
        final data = response['data'];
        debugPrint('Conversation loaded: $data');
        conversation.value = ConversationModel.fromFirestore(data);
      } else {
        debugPrint('Failed to load conversation: ${response['message']}');
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
        debugPrint('Error streaming messages: $error');
        Get.snackbar('Error', 'Failed to load messages');
      },
    );
  }

  Future<void> _markAsRead() async {
    if (conversationId == null) return;
    await _chatRepository.markAsRead(conversationId!);
  }

  /// Check if user is verified by admin (fetches fresh data from Firestore)
  Future<bool> _checkAdminVerification() async {
    final isVerified = await _authRepository.isAdminVerified();
    debugPrint('Admin verification status: $isVerified');
    if (!isVerified) {
      Get.snackbar(
        'Account Not Verified',
        'Your account is pending verification by admin. You can complete your profile while waiting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // return false; // TEMPORARILY DISABLED FOR DEBUGGING
      return true; 
    }
    return true;
  }

  Future<void> sendMessage() async {
    debugPrint('Attempting to send message...');
    
    // Check if initializing
    if (conversationId == null) {
       if (isLoading.value) {
         Get.snackbar('Please wait', 'Initializing conversation...');
         return;
       }
       debugPrint('Error: conversationId is null and not loading');
       Get.snackbar('Error', 'Conversation not initialized properly');
       return;
    }

    if (messageController.text.trim().isEmpty) {
       debugPrint('Error: Message is empty');
       return;
    }
    
    // Check verification but allow proceeding for now (based on modification above)
    if (!await _checkAdminVerification()) {
       debugPrint('Blocked by admin verification');
       return;
    }

    try {
      final content = messageController.text.trim();
      messageController.clear();

      debugPrint('Sending message: $content');
      await _chatRepository.sendMessage(conversationId!, content);
      debugPrint('Message sent successfully');
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message: $e');
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
