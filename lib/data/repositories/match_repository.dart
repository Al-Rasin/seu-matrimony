import 'package:get/get.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/network/api_response.dart';
import '../models/match_model.dart';
import '../models/filter_model.dart';
import '../providers/match_provider.dart';

export '../models/filter_model.dart';

/// Repository for match-related operations
/// Handles both mock data and real API calls
class MatchRepository {
  MatchProvider? _matchProvider;

  MatchProvider get matchProvider {
    _matchProvider ??= Get.find<MatchProvider>();
    return _matchProvider!;
  }

  // ==================== MATCHES ====================

  /// Get all matches with optional filters
  Future<PaginatedResponse<MatchModel>> getMatches({
    int page = 1,
    int perPage = 10,
    MatchFilter? filter,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(page: page, perPage: perPage, filter: filter);
    }

    return matchProvider.getMatches(
      page: page,
      perPage: perPage,
      filters: filter?.toQueryParams(),
    );
  }

  /// Get recommended matches
  Future<PaginatedResponse<MatchModel>> getRecommendedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(page: page, perPage: perPage, recommended: true);
    }

    return matchProvider.getRecommendedMatches(page: page, perPage: perPage);
  }

  /// Get newly joined users
  Future<PaginatedResponse<MatchModel>> getNewlyJoined({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(page: page, perPage: perPage, newlyJoined: true);
    }

    return matchProvider.getNewlyJoined(page: page, perPage: perPage);
  }

  /// Search matches
  Future<PaginatedResponse<MatchModel>> searchMatches({
    required String query,
    int page = 1,
    int perPage = 10,
    MatchFilter? filter,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        searchQuery: query,
        filter: filter,
      );
    }

    return matchProvider.searchMatches(
      query: query,
      page: page,
      perPage: perPage,
      filters: filter?.toQueryParams(),
    );
  }

  /// Get match profile by ID
  Future<MatchModel?> getMatchProfile(String matchId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final match = _mockMatches.firstWhereOrNull((m) => m.id == matchId);
      return match;
    }

    final response = await matchProvider.getMatchProfile(matchId);
    return response.data;
  }

  // ==================== INTERESTS ====================

  /// Send interest to a match
  Future<bool> sendInterest(String matchId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Update mock data
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(
          interestStatus: InterestStatus.sent,
        );
      }
      return true;
    }

    final response = await matchProvider.sendInterest(matchId);
    return response.success;
  }

  /// Accept interest
  Future<bool> acceptInterest(String interestId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final response = await matchProvider.acceptInterest(interestId);
    return response.success;
  }

  /// Reject interest
  Future<bool> rejectInterest(String interestId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final response = await matchProvider.rejectInterest(interestId);
    return response.success;
  }

  /// Get sent interests
  Future<PaginatedResponse<MatchModel>> getSentInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.sent,
      );
    }

    return matchProvider.getSentInterests(page: page, perPage: perPage);
  }

  /// Get received interests
  Future<PaginatedResponse<MatchModel>> getReceivedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.received,
      );
    }

    return matchProvider.getReceivedInterests(page: page, perPage: perPage);
  }

  /// Get accepted connections
  Future<PaginatedResponse<MatchModel>> getAcceptedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.accepted,
      );
    }

    return matchProvider.getAcceptedInterests(page: page, perPage: perPage);
  }

  // ==================== SHORTLIST ====================

  /// Add to shortlist
  Future<bool> addToShortlist(String matchId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(isShortlisted: true);
      }
      return true;
    }

    final response = await matchProvider.addToShortlist(matchId);
    return response.success;
  }

  /// Remove from shortlist
  Future<bool> removeFromShortlist(String matchId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(isShortlisted: false);
      }
      return true;
    }

    final response = await matchProvider.removeFromShortlist(matchId);
    return response.success;
  }

  /// Get shortlisted matches
  Future<PaginatedResponse<MatchModel>> getShortlistedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(page: page, perPage: perPage, shortlistedOnly: true);
    }

    return matchProvider.getShortlistedMatches(page: page, perPage: perPage);
  }

  // ==================== PROFILE VIEWS ====================

  /// Record profile view
  Future<void> recordProfileView(String matchId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    await matchProvider.recordProfileView(matchId);
  }

  /// Get who viewed me
  Future<PaginatedResponse<MatchModel>> getWhoViewedMe({
    int page = 1,
    int perPage = 10,
  }) async {
    if (MockDataService.useMockData) {
      return _getMockMatches(page: page, perPage: perPage);
    }

    return matchProvider.getWhoViewedMe(page: page, perPage: perPage);
  }

  // ==================== BLOCK & REPORT ====================

  /// Block user
  Future<bool> blockUser(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final response = await matchProvider.blockUser(userId);
    return response.success;
  }

  /// Unblock user
  Future<bool> unblockUser(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final response = await matchProvider.unblockUser(userId);
    return response.success;
  }

  /// Report user
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    final response = await matchProvider.reportUser(
      userId: userId,
      reason: reason,
      description: description,
    );
    return response.success;
  }

  // ==================== MOCK DATA ====================

  /// Mock matches data
  final List<MatchModel> _mockMatches = [
    MatchModel(
      id: 'match_001',
      fullName: 'Fatima Rahman',
      profilePhoto: null,
      age: 25,
      gender: 'female',
      height: 160.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Computer Science & Engineering',
      highestEducation: "Bachelor's Degree",
      occupation: 'Software Engineer',
      currentCity: 'Dhaka',
      bio: 'A passionate software developer looking for a kind and understanding life partner.',
      profileCompletionPercentage: 90,
      isVerified: true,
      isOnline: true,
      interestStatus: InterestStatus.none,
      isShortlisted: false,
    ),
    MatchModel(
      id: 'match_002',
      fullName: 'Ayesha Khan',
      profilePhoto: null,
      age: 24,
      gender: 'female',
      height: 157.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Business Administration',
      highestEducation: "Master's Degree",
      occupation: 'Marketing Manager',
      currentCity: 'Dhaka',
      bio: 'Looking for someone who values family and career equally.',
      profileCompletionPercentage: 85,
      isVerified: true,
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      interestStatus: InterestStatus.none,
      isShortlisted: true,
    ),
    MatchModel(
      id: 'match_003',
      fullName: 'Nusrat Jahan',
      profilePhoto: null,
      age: 26,
      gender: 'female',
      height: 162.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Electrical Engineering',
      highestEducation: "Bachelor's Degree",
      occupation: 'Electrical Engineer',
      currentCity: 'Chittagong',
      bio: 'Simple girl with big dreams. Looking for a supportive partner.',
      profileCompletionPercentage: 80,
      isVerified: true,
      isOnline: true,
      interestStatus: InterestStatus.sent,
      isShortlisted: false,
    ),
    MatchModel(
      id: 'match_004',
      fullName: 'Sabrina Ahmed',
      profilePhoto: null,
      age: 23,
      gender: 'female',
      height: 155.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Pharmacy',
      highestEducation: "Bachelor's Degree",
      occupation: 'Pharmacist',
      currentCity: 'Dhaka',
      bio: 'Healthcare professional seeking a caring and understanding partner.',
      profileCompletionPercentage: 75,
      isVerified: false,
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      interestStatus: InterestStatus.received,
      isShortlisted: false,
    ),
    MatchModel(
      id: 'match_005',
      fullName: 'Tahmina Islam',
      profilePhoto: null,
      age: 27,
      gender: 'female',
      height: 165.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Architecture',
      highestEducation: "Master's Degree",
      occupation: 'Architect',
      currentCity: 'Dhaka',
      bio: 'Creative mind looking for an intellectual partner.',
      profileCompletionPercentage: 95,
      isVerified: true,
      isOnline: true,
      interestStatus: InterestStatus.accepted,
      isShortlisted: true,
    ),
    MatchModel(
      id: 'match_006',
      fullName: 'Mariam Begum',
      profilePhoto: null,
      age: 25,
      gender: 'female',
      height: 158.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'English',
      highestEducation: "Bachelor's Degree",
      occupation: 'Teacher',
      currentCity: 'Sylhet',
      bio: 'Teacher by profession, kind by heart.',
      profileCompletionPercentage: 70,
      isVerified: true,
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 5)),
      interestStatus: InterestStatus.none,
      isShortlisted: false,
    ),
    MatchModel(
      id: 'match_007',
      fullName: 'Sadia Akter',
      profilePhoto: null,
      age: 24,
      gender: 'female',
      height: 160.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Law',
      highestEducation: "Bachelor's Degree",
      occupation: 'Lawyer',
      currentCity: 'Dhaka',
      bio: 'Justice-loving individual seeking a respectful partner.',
      profileCompletionPercentage: 88,
      isVerified: true,
      isOnline: true,
      interestStatus: InterestStatus.none,
      isShortlisted: false,
    ),
    MatchModel(
      id: 'match_008',
      fullName: 'Rabeya Sultana',
      profilePhoto: null,
      age: 26,
      gender: 'female',
      height: 163.0,
      religion: 'Islam',
      maritalStatus: 'Never Married',
      department: 'Economics',
      highestEducation: "Master's Degree",
      occupation: 'Bank Officer',
      currentCity: 'Dhaka',
      bio: 'Finance professional looking for a stable and loving relationship.',
      profileCompletionPercentage: 82,
      isVerified: true,
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      interestStatus: InterestStatus.none,
      isShortlisted: false,
    ),
  ];

  /// Get mock matches with filtering and pagination
  Future<PaginatedResponse<MatchModel>> _getMockMatches({
    int page = 1,
    int perPage = 10,
    String? searchQuery,
    MatchFilter? filter,
    bool recommended = false,
    bool newlyJoined = false,
    bool shortlistedOnly = false,
    InterestStatus? interestStatus,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    var matches = List<MatchModel>.from(_mockMatches);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      matches = matches.where((m) {
        return m.fullName.toLowerCase().contains(query) ||
            (m.occupation?.toLowerCase().contains(query) ?? false) ||
            (m.currentCity?.toLowerCase().contains(query) ?? false) ||
            (m.department?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply shortlist filter
    if (shortlistedOnly) {
      matches = matches.where((m) => m.isShortlisted).toList();
    }

    // Apply interest status filter
    if (interestStatus != null) {
      matches = matches.where((m) => m.interestStatus == interestStatus).toList();
    }

    // Apply custom filters
    if (filter != null) {
      matches = _applyFilters(matches, filter);
    }

    // Calculate pagination
    final total = matches.length;
    final totalPages = (total / perPage).ceil();
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;

    final paginatedItems = matches.sublist(
      startIndex.clamp(0, total),
      endIndex.clamp(0, total),
    );

    return PaginatedResponse<MatchModel>(
      items: paginatedItems,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: totalPages == 0 ? 1 : totalPages,
        perPage: perPage,
        total: total,
        hasMorePages: page < totalPages,
      ),
    );
  }

  /// Apply filters to matches list
  List<MatchModel> _applyFilters(List<MatchModel> matches, MatchFilter filter) {
    return matches.where((m) {
      // Age filter
      if (filter.minAge != null && (m.age ?? 0) < filter.minAge!) return false;
      if (filter.maxAge != null && (m.age ?? 100) > filter.maxAge!) return false;

      // Height filter
      if (filter.minHeight != null && (m.height ?? 0) < filter.minHeight!) return false;
      if (filter.maxHeight != null && (m.height ?? 300) > filter.maxHeight!) return false;

      // Religion filter
      if (filter.religion != null &&
          filter.religion!.isNotEmpty &&
          m.religion?.toLowerCase() != filter.religion!.toLowerCase()) {
        return false;
      }

      // Marital status filter
      if (filter.maritalStatus != null &&
          filter.maritalStatus!.isNotEmpty &&
          m.maritalStatus?.toLowerCase() != filter.maritalStatus!.toLowerCase()) {
        return false;
      }

      // Education filter
      if (filter.education != null &&
          filter.education!.isNotEmpty &&
          m.highestEducation?.toLowerCase() != filter.education!.toLowerCase()) {
        return false;
      }

      // City filter
      if (filter.city != null &&
          filter.city!.isNotEmpty &&
          m.currentCity?.toLowerCase() != filter.city!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }
}
