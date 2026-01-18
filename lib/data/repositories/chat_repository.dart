import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Repository for chat-related operations
/// Handles both mock data and Firestore
class ChatRepository {
  // Lazy initialization for Firebase services
  FirestoreService? _firestoreService;
  AuthService? _authService;

  FirestoreService get firestoreService {
    _firestoreService ??= Get.find<FirestoreService>();
    return _firestoreService!;
  }

  AuthService get authService {
    _authService ??= Get.find<AuthService>();
    return _authService!;
  }

  /// Check if using Firebase or mock data
  bool get useFirebase => !MockDataService.useMockData;

  /// Get current user ID
  String? get currentUserId => authService.currentUserId;

  // ==================== MOCK DATA ====================

  final List<Map<String, dynamic>> _mockConversations = [
    {
      'id': 'conv_001',
      'participantId': 'user_002',
      'participantName': 'Fatima Ahmed',
      'participantPhoto': null,
      'lastMessage': 'Hello! How are you?',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'unreadCount': 2,
      'isOnline': true,
    },
    {
      'id': 'conv_002',
      'participantId': 'user_003',
      'participantName': 'Ayesha Rahman',
      'participantPhoto': null,
      'lastMessage': 'Thanks for accepting my interest!',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'unreadCount': 0,
      'isOnline': false,
    },
    {
      'id': 'conv_003',
      'participantId': 'user_004',
      'participantName': 'Nusrat Jahan',
      'participantPhoto': null,
      'lastMessage': 'Nice to meet you!',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'unreadCount': 1,
      'isOnline': true,
    },
  ];

  final List<Map<String, dynamic>> _mockMessages = [
    {
      'id': 'msg_001',
      'senderId': 'user_002',
      'content': 'Hello! How are you?',
      'type': 'text',
      'sentAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'isRead': false,
    },
    {
      'id': 'msg_002',
      'senderId': 'user_001',
      'content': 'I am fine, thank you! How about you?',
      'type': 'text',
      'sentAt': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
      'isRead': true,
    },
    {
      'id': 'msg_003',
      'senderId': 'user_002',
      'content': 'I am doing great! Would love to know more about you.',
      'type': 'text',
      'sentAt': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
      'isRead': false,
    },
  ];

  // ==================== CONVERSATIONS ====================

  /// Get all conversations for current user
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Query conversations where current user is a participant
      final conversations = await firestoreService.query(
        collection: FirebaseConstants.conversationsCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldParticipants,
            operator: QueryOperator.arrayContains,
            value: userId,
          ),
        ],
        orderBy: FirebaseConstants.fieldLastMessageAt,
        descending: true,
        limit: limit,
      );

      // Enrich conversations with participant details
      final enrichedConversations = await Future.wait(
        conversations.map((conv) => _enrichConversation(conv, userId)),
      );

      return {
        'success': true,
        'data': enrichedConversations,
        'total': enrichedConversations.length,
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'data': _mockConversations,
      'total': _mockConversations.length,
    };
  }

  /// Stream conversations (real-time)
  Stream<List<ConversationModel>> streamConversations() {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) {
        return Stream.value([]);
      }

      return firestoreService.queryStream(
        collection: FirebaseConstants.conversationsCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldParticipants,
            operator: QueryOperator.arrayContains,
            value: userId,
          ),
        ],
        orderBy: FirebaseConstants.fieldLastMessageAt,
        descending: true,
      ).asyncMap((conversations) async {
        final enriched = await Future.wait(
          conversations.map((conv) => _enrichConversation(conv, userId)),
        );
        return enriched.map((c) => ConversationModel.fromFirestore(c)).toList();
      });
    }

    // Mock - return empty stream
    return Stream.value([]);
  }

  /// Get single conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final conv = await firestoreService.getById(
        collection: FirebaseConstants.conversationsCollection,
        documentId: conversationId,
      );

      if (conv == null) {
        throw Exception('Conversation not found');
      }

      final enriched = await _enrichConversation(conv, userId);

      return {
        'success': true,
        'data': enriched,
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 200));
    final conv = _mockConversations.firstWhere(
      (c) => c['id'] == conversationId,
      orElse: () => _mockConversations.first,
    );
    return {
      'success': true,
      'data': conv,
    };
  }

  /// Create or get existing conversation with a user
  Future<Map<String, dynamic>> createConversation(String otherUserId) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Check if conversation already exists
      final existing = await _findExistingConversation(userId, otherUserId);
      if (existing != null) {
        return {
          'success': true,
          'data': existing,
          'isExisting': true,
        };
      }

      // Create new conversation
      final conversationId = await firestoreService.create(
        collection: FirebaseConstants.conversationsCollection,
        data: {
          FirebaseConstants.fieldParticipants: [userId, otherUserId],
          FirebaseConstants.fieldLastMessage: null,
          FirebaseConstants.fieldLastMessageAt: FieldValue.serverTimestamp(),
          FirebaseConstants.fieldUnreadCount: 0,
        },
      );

      return {
        'success': true,
        'data': {
          'id': conversationId,
          'participants': [userId, otherUserId],
        },
        'isExisting': false,
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'data': {
        'id': 'conv_new_${DateTime.now().millisecondsSinceEpoch}',
        'participantId': otherUserId,
      },
    };
  }

  // ==================== MESSAGES ====================

  /// Get messages for a conversation
  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    if (useFirebase) {
      final messages = await firestoreService.getFromSubcollection(
        parentCollection: FirebaseConstants.conversationsCollection,
        parentDocumentId: conversationId,
        subcollection: FirebaseConstants.messagesSubcollection,
        orderBy: FirebaseConstants.fieldCreatedAt,
        descending: true,
        limit: limit,
      );

      return {
        'success': true,
        'data': messages,
        'total': messages.length,
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'data': _mockMessages,
      'total': _mockMessages.length,
    };
  }

  /// Stream messages (real-time)
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    if (useFirebase) {
      return firestoreService.streamSubcollection(
        parentCollection: FirebaseConstants.conversationsCollection,
        parentDocumentId: conversationId,
        subcollection: FirebaseConstants.messagesSubcollection,
        orderBy: FirebaseConstants.fieldCreatedAt,
        descending: false,
      ).map((messages) {
        return messages.map((m) => MessageModel.fromFirestore(m)).toList();
      });
    }

    // Mock - return empty stream
    return Stream.value([]);
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content, {
    String type = 'text',
  }) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Create message in subcollection
      final messageId = await firestoreService.createInSubcollection(
        parentCollection: FirebaseConstants.conversationsCollection,
        parentDocumentId: conversationId,
        subcollection: FirebaseConstants.messagesSubcollection,
        data: {
          FirebaseConstants.fieldSenderId: userId,
          FirebaseConstants.fieldContent: content,
          FirebaseConstants.fieldType: type,
          FirebaseConstants.fieldIsRead: false,
        },
      );

      // Update conversation with last message
      await firestoreService.update(
        collection: FirebaseConstants.conversationsCollection,
        documentId: conversationId,
        data: {
          FirebaseConstants.fieldLastMessage: content,
          FirebaseConstants.fieldLastMessageAt: FieldValue.serverTimestamp(),
        },
      );

      // Increment unread count for other participants
      await _incrementUnreadCount(conversationId, userId);

      return {
        'success': true,
        'data': {
          'id': messageId,
          'senderId': userId,
          'content': content,
          'type': type,
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
        },
      };
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'success': true,
      'data': {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'senderId': 'user_001',
        'content': content,
        'type': type,
        'sentAt': DateTime.now().toIso8601String(),
        'isRead': false,
      },
    };
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) return;

      // Reset unread count
      await firestoreService.update(
        collection: FirebaseConstants.conversationsCollection,
        documentId: conversationId,
        data: {
          'unreadCount_$userId': 0,
        },
      );

      // Mark all unread messages as read
      final messages = await firestoreService.getFromSubcollection(
        parentCollection: FirebaseConstants.conversationsCollection,
        parentDocumentId: conversationId,
        subcollection: FirebaseConstants.messagesSubcollection,
      );

      for (final message in messages) {
        if (message[FirebaseConstants.fieldSenderId] != userId &&
            message[FirebaseConstants.fieldIsRead] == false) {
          await firestoreService.firestore!
              .collection(FirebaseConstants.conversationsCollection)
              .doc(conversationId)
              .collection(FirebaseConstants.messagesSubcollection)
              .doc(message['id'])
              .update({
            FirebaseConstants.fieldIsRead: true,
            FirebaseConstants.fieldReadAt: FieldValue.serverTimestamp(),
          });
        }
      }
      return;
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Set typing status
  Future<void> setTypingStatus(String conversationId, bool isTyping) async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) return;

      await firestoreService.update(
        collection: FirebaseConstants.conversationsCollection,
        documentId: conversationId,
        data: {
          '${FirebaseConstants.fieldTypingStatus}.$userId': isTyping ? FieldValue.serverTimestamp() : null,
        },
      );
    }
  }

  /// Stream typing status
  Stream<Map<String, dynamic>> streamTypingStatus(String conversationId) {
    if (useFirebase) {
      return firestoreService.getByIdStream(
        collection: FirebaseConstants.conversationsCollection,
        documentId: conversationId,
      ).map((data) {
        return (data?[FirebaseConstants.fieldTypingStatus] as Map<String, dynamic>?) ?? {};
      });
    }
    return Stream.value({});
  }

  // ==================== BLOCK/REPORT ====================

  /// Block a user
  Future<void> blockUser(String userId) async {
    if (useFirebase) {
      final currentId = currentUserId;
      if (currentId == null) return;

      await firestoreService.create(
        collection: FirebaseConstants.blocksCollection,
        data: {
          FirebaseConstants.fieldBlockerId: currentId,
          FirebaseConstants.fieldBlockedUserId: userId,
        },
      );
      return;
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Unblock a user
  Future<void> unblockUser(String userId) async {
    if (useFirebase) {
      final currentId = currentUserId;
      if (currentId == null) return;

      // Find and delete the block document
      final blocks = await firestoreService.query(
        collection: FirebaseConstants.blocksCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldBlockerId,
            operator: QueryOperator.isEqualTo,
            value: currentId,
          ),
          QueryFilter(
            field: FirebaseConstants.fieldBlockedUserId,
            operator: QueryOperator.isEqualTo,
            value: userId,
          ),
        ],
      );

      for (final block in blocks) {
        await firestoreService.delete(
          collection: FirebaseConstants.blocksCollection,
          documentId: block['id'],
        );
      }
      return;
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Check if user is blocked
  Future<bool> isUserBlocked(String userId) async {
    if (useFirebase) {
      final currentId = currentUserId;
      if (currentId == null) return false;

      final blocks = await firestoreService.query(
        collection: FirebaseConstants.blocksCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldBlockerId,
            operator: QueryOperator.isEqualTo,
            value: currentId,
          ),
          QueryFilter(
            field: FirebaseConstants.fieldBlockedUserId,
            operator: QueryOperator.isEqualTo,
            value: userId,
          ),
        ],
      );

      return blocks.isNotEmpty;
    }

    return false;
  }

  /// Report a user
  Future<void> reportUser(String userId, String reason, String description) async {
    if (useFirebase) {
      final currentId = currentUserId;
      if (currentId == null) return;

      await firestoreService.create(
        collection: FirebaseConstants.reportsCollection,
        data: {
          FirebaseConstants.fieldReporterId: currentId,
          FirebaseConstants.fieldReportedUserId: userId,
          FirebaseConstants.fieldReason: reason,
          FirebaseConstants.fieldDescription: description,
          FirebaseConstants.fieldStatus: FirebaseConstants.reportStatusPending,
        },
      );
      return;
    }

    // Mock data fallback
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ==================== HELPER METHODS ====================

  /// Enrich conversation with participant details
  Future<Map<String, dynamic>> _enrichConversation(
    Map<String, dynamic> conv,
    String currentUserId,
  ) async {
    final participants = List<String>.from(conv['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return conv;

    // Fetch other user's details
    final otherUser = await firestoreService.getById(
      collection: FirebaseConstants.usersCollection,
      documentId: otherUserId,
    );

    return {
      ...conv,
      'participantId': otherUserId,
      'participantName': otherUser?[FirebaseConstants.fieldFullName] ?? 'Unknown',
      'participantPhoto': otherUser?[FirebaseConstants.fieldProfilePhoto],
      'isOnline': otherUser?[FirebaseConstants.fieldIsOnline] ?? false,
    };
  }

  /// Find existing conversation between two users
  Future<Map<String, dynamic>?> _findExistingConversation(
    String userId1,
    String userId2,
  ) async {
    // Query conversations containing userId1
    final conversations = await firestoreService.query(
      collection: FirebaseConstants.conversationsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldParticipants,
          operator: QueryOperator.arrayContains,
          value: userId1,
        ),
      ],
    );

    // Find one that also contains userId2
    for (final conv in conversations) {
      final participants = List<String>.from(conv['participants'] ?? []);
      if (participants.contains(userId2)) {
        return conv;
      }
    }

    return null;
  }

  /// Increment unread count for other participants
  Future<void> _incrementUnreadCount(String conversationId, String senderId) async {
    final conv = await firestoreService.getById(
      collection: FirebaseConstants.conversationsCollection,
      documentId: conversationId,
    );

    if (conv == null) return;

    final participants = List<String>.from(conv['participants'] ?? []);

    // Increment unread count for all participants except sender
    for (final participantId in participants) {
      if (participantId != senderId) {
        await firestoreService.firestore!
            .collection(FirebaseConstants.conversationsCollection)
            .doc(conversationId)
            .update({
          'unreadCount_$participantId': FieldValue.increment(1),
        });
      }
    }
  }

  /// Get unread count for current user
  Future<int> getUnreadCount() async {
    if (useFirebase) {
      final userId = currentUserId;
      if (userId == null) return 0;

      final conversations = await firestoreService.query(
        collection: FirebaseConstants.conversationsCollection,
        filters: [
          QueryFilter(
            field: FirebaseConstants.fieldParticipants,
            operator: QueryOperator.arrayContains,
            value: userId,
          ),
        ],
      );

      int totalUnread = 0;
      for (final conv in conversations) {
        totalUnread += (conv['unreadCount_$userId'] as int?) ?? 0;
      }

      return totalUnread;
    }

    return 3; // Mock count
  }
}
