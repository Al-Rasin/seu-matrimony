import '../../core/services/mock_data_service.dart';

class InterestRepository {
  final List<Map<String, dynamic>> _mockSentInterests = [
    {
      'id': 'interest_001',
      'receiverId': 'user_002',
      'receiverName': 'Fatima Ahmed',
      'status': 'pending',
      'sentAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'interest_002',
      'receiverId': 'user_003',
      'receiverName': 'Ayesha Rahman',
      'status': 'accepted',
      'sentAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
  ];

  final List<Map<String, dynamic>> _mockReceivedInterests = [
    {
      'id': 'interest_003',
      'senderId': 'user_004',
      'senderName': 'Nusrat Jahan',
      'status': 'pending',
      'sentAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'interest_004',
      'senderId': 'user_005',
      'senderName': 'Maliha Khan',
      'status': 'pending',
      'sentAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
  ];

  Future<Map<String, dynamic>> sendInterest(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'message': 'Interest sent successfully',
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getSentInterests({
    int page = 1,
    int limit = 20,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockSentInterests,
        'total': _mockSentInterests.length,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getReceivedInterests({
    int page = 1,
    int limit = 20,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockReceivedInterests,
        'total': _mockReceivedInterests.length,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> acceptInterest(String interestId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'message': 'Interest accepted',
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> rejectInterest(String interestId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'message': 'Interest rejected',
      };
    }
    throw Exception('Backend not available');
  }
}
