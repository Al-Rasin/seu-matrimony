import '../../core/services/mock_data_service.dart';

class ChatRepository {
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

  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockConversations,
        'total': _mockConversations.length,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    if (MockDataService.useMockData) {
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
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> createConversation(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': {
          'id': 'conv_new_${DateTime.now().millisecondsSinceEpoch}',
          'participantId': userId,
        },
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockMessages,
        'total': _mockMessages.length,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content, {
    String type = 'text',
  }) async {
    if (MockDataService.useMockData) {
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
    throw Exception('Backend not available');
  }

  Future<void> markAsRead(String conversationId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<void> blockUser(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<void> unblockUser(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<void> reportUser(String userId, String reason, String description) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    throw Exception('Backend not available');
  }
}
