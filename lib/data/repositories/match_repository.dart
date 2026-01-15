import '../../core/services/mock_data_service.dart';

class MatchRepository {
  // Mock recommended matches data
  final List<Map<String, dynamic>> _mockRecommendedMatches = [
    {
      'id': 'match_001',
      'fullName': 'Fatima Ahmed',
      'age': 26,
      'occupation': 'Doctor',
      'city': 'Dhaka',
      'profilePhoto': null,
    },
    {
      'id': 'match_002',
      'fullName': 'Ayesha Rahman',
      'age': 24,
      'occupation': 'Software Engineer',
      'city': 'Chittagong',
      'profilePhoto': null,
    },
    {
      'id': 'match_003',
      'fullName': 'Nusrat Jahan',
      'age': 25,
      'occupation': 'Teacher',
      'city': 'Sylhet',
      'profilePhoto': null,
    },
    {
      'id': 'match_004',
      'fullName': 'Maliha Khan',
      'age': 27,
      'occupation': 'Banker',
      'city': 'Dhaka',
      'profilePhoto': null,
    },
  ];

  Future<Map<String, dynamic>> getMatches({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'data': _mockRecommendedMatches,
        'page': page,
        'total': _mockRecommendedMatches.length,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getRecommendedMatches() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches,
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getNewlyJoined() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches.reversed.toList(),
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> searchMatches(
      Map<String, dynamic> filters) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'data': _mockRecommendedMatches,
      };
    }
    throw Exception('Backend not available');
  }

  Future<void> recordProfileView(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getWhoViewedMe() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches.take(2).toList(),
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getViewedByMe() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches.skip(1).take(2).toList(),
      };
    }
    throw Exception('Backend not available');
  }

  Future<void> addToShortlist(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<void> removeFromShortlist(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getMyShortlist() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches.take(1).toList(),
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getShortlistedMe() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': _mockRecommendedMatches.skip(2).take(1).toList(),
      };
    }
    throw Exception('Backend not available');
  }
}
