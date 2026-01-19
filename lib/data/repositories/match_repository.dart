import 'package:get/get.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/match_model.dart';
import '../models/filter_model.dart';
import '../models/paginated_response.dart';

export '../models/filter_model.dart';

/// Repository for match-related operations
/// Handles both mock data and Firestore
class MatchRepository {
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

  String? get currentUserId => authService.currentUserId;

  // ==================== MATCHES ====================

  /// Get all matches with optional filters
  Future<PaginatedResponse<MatchModel>> getMatches({
    int page = 1,
    int perPage = 10,
    MatchFilter? filter,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(page: page, perPage: perPage, filter: filter);
    }

    // Fetch all active users and filter in memory to avoid complex index requirements
    // This is simpler and works without composite indexes
    final results = await firestoreService.getAll(
      collection: FirebaseConstants.usersCollection,
      limit: 200, // Reasonable limit for a matrimony app
    );

    // Convert to MatchModel and filter
    var matches = results
        .where((data) => data['id'] != currentUserId) // Exclude current user
        .where((data) => data['profileStatus'] == 'active') // Only active profiles
        .map((data) => MatchModel.fromFirestore(data))
        .toList();

    // Apply filters in memory
    if (filter != null) {
      matches = matches.where((m) {
        if (filter.gender != null && filter.gender!.isNotEmpty && m.gender?.toLowerCase() != filter.gender!.toLowerCase()) return false;
        if (filter.department != null && filter.department!.isNotEmpty && m.department != filter.department) return false;
        if (filter.religion != null && filter.religion!.isNotEmpty && m.religion != filter.religion) return false;
        if (filter.maritalStatus != null && filter.maritalStatus!.isNotEmpty && m.maritalStatus != filter.maritalStatus) return false;
        if (filter.city != null && filter.city!.isNotEmpty && m.currentCity != filter.city) return false;
        if (filter.verifiedOnly == true && !m.isVerified) return false;
        return true;
      }).toList();

      matches = _applyLocalFilters(matches, filter);
    }

    // Sort by lastSeen/online status (online users first, then by lastSeen)
    matches.sort((a, b) {
      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;
      return (b.lastSeen ?? DateTime(2000)).compareTo(a.lastSeen ?? DateTime(2000));
    });

    // Get shortlist and interest status for each match
    matches = await _enrichMatchesWithStatus(matches);

    // Paginate
    final startIndex = (page - 1) * perPage;
    final paginatedMatches = matches.skip(startIndex).take(perPage).toList();

    return PaginatedResponse(
      items: paginatedMatches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: (matches.length / perPage).ceil().clamp(1, 100),
        perPage: perPage,
        total: matches.length,
        hasMorePages: startIndex + perPage < matches.length,
      ),
    );
  }

  /// Get recommended matches
  Future<PaginatedResponse<MatchModel>> getRecommendedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(page: page, perPage: perPage, recommended: true);
    }

    // Fetch all users and filter in memory to avoid index requirements
    final results = await firestoreService.getAll(
      collection: FirebaseConstants.usersCollection,
      limit: 200,
    );

    var matches = results
        .where((data) => data['id'] != currentUserId)
        .where((data) => data['isVerified'] == true)
        .where((data) => data['profileStatus'] == 'active')
        .map((data) => MatchModel.fromFirestore(data))
        .toList();

    // Sort: online first, then by verification
    matches.sort((a, b) {
      if (a.isOnline && !b.isOnline) return -1;
      if (!a.isOnline && b.isOnline) return 1;
      return 0;
    });

    matches = await _enrichMatchesWithStatus(matches);

    // Paginate
    final startIndex = (page - 1) * perPage;
    final paginatedMatches = matches.skip(startIndex).take(perPage).toList();

    return PaginatedResponse(
      items: paginatedMatches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: (matches.length / perPage).ceil().clamp(1, 100),
        perPage: perPage,
        total: matches.length,
        hasMorePages: startIndex + perPage < matches.length,
      ),
    );
  }

  /// Get newly joined users
  Future<PaginatedResponse<MatchModel>> getNewlyJoined({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(page: page, perPage: perPage, newlyJoined: true);
    }

    // Simple query without complex filtering
    final results = await firestoreService.getAll(
      collection: FirebaseConstants.usersCollection,
      limit: 100,
    );

    var matches = results
        .where((data) => data['id'] != currentUserId)
        .where((data) => data['profileStatus'] == 'active')
        .map((data) => MatchModel.fromFirestore(data))
        .toList();

    matches = await _enrichMatchesWithStatus(matches);

    // Paginate
    final startIndex = (page - 1) * perPage;
    final paginatedMatches = matches.skip(startIndex).take(perPage).toList();

    return PaginatedResponse(
      items: paginatedMatches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: (matches.length / perPage).ceil().clamp(1, 100),
        perPage: perPage,
        total: matches.length,
        hasMorePages: startIndex + perPage < matches.length,
      ),
    );
  }

  /// Search matches
  Future<PaginatedResponse<MatchModel>> searchMatches({
    required String query,
    int page = 1,
    int perPage = 10,
    MatchFilter? filter,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        searchQuery: query,
        filter: filter,
      );
    }

    // Firestore doesn't support full-text search natively
    // For production, consider using Algolia or similar
    // For now, fetch and filter in memory
    final results = await firestoreService.getAll(
      collection: FirebaseConstants.usersCollection,
      limit: 100,
    );

    final searchLower = query.toLowerCase();
    var matches = results
        .where((data) {
          final name = (data['fullName'] as String? ?? '').toLowerCase();
          final city = (data['currentCity'] as String? ?? '').toLowerCase();
          final occupation = (data['occupation'] as String? ?? '').toLowerCase();
          final department = (data['department'] as String? ?? '').toLowerCase();
          return name.contains(searchLower) ||
              city.contains(searchLower) ||
              occupation.contains(searchLower) ||
              department.contains(searchLower);
        })
        .where((data) => data['id'] != currentUserId)
        .map((data) => MatchModel.fromFirestore(data))
        .toList();

    if (filter != null) {
      matches = _applyLocalFilters(matches, filter);
    }

    matches = await _enrichMatchesWithStatus(matches);

    return PaginatedResponse(
      items: matches.take(perPage).toList(),
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: (matches.length / perPage).ceil().clamp(1, 100),
        perPage: perPage,
        total: matches.length,
        hasMorePages: matches.length > perPage,
      ),
    );
  }

  /// Get match profile by ID
  Future<MatchModel?> getMatchProfile(String matchId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      final match = _mockMatches.firstWhereOrNull((m) => m.id == matchId);
      return match;
    }

    final data = await firestoreService.getById(
      collection: FirebaseConstants.usersCollection,
      documentId: matchId,
    );

    if (data == null) return null;

    var match = MatchModel.fromFirestore(data);
    final enriched = await _enrichMatchesWithStatus([match]);
    return enriched.isNotEmpty ? enriched.first : match;
  }

  /// Stream received interests (real-time)
  Stream<List<MatchModel>> streamReceivedInterests() {
    if (!useFirebase || currentUserId == null) return Stream.value([]);

    return firestoreService.queryStream(
      collection: FirebaseConstants.interestsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldToUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldStatus,
          operator: QueryOperator.isEqualTo,
          value: FirebaseConstants.statusPending,
        ),
      ],
    ).asyncMap((interests) async {
      final matches = <MatchModel>[];
      for (final interest in interests) {
        final userId = interest[FirebaseConstants.fieldFromUserId] as String?;
        if (userId != null) {
          final userData = await firestoreService.getById(
            collection: FirebaseConstants.usersCollection,
            documentId: userId,
          );
          if (userData != null) {
            matches.add(MatchModel.fromFirestore(userData).copyWith(
              interestStatus: InterestStatus.received,
              interestId: interest['id'] as String?,
            ));
          }
        }
      }
      return matches;
    });
  }

  /// Stream sent interests (real-time)
  Stream<List<MatchModel>> streamSentInterests() {
    if (!useFirebase || currentUserId == null) return Stream.value([]);

    return firestoreService.queryStream(
      collection: FirebaseConstants.interestsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldFromUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
      ],
    ).asyncMap((interests) async {
      final matches = <MatchModel>[];
      for (final interest in interests) {
        final userId = interest[FirebaseConstants.fieldToUserId] as String?;
        if (userId != null) {
          final userData = await firestoreService.getById(
            collection: FirebaseConstants.usersCollection,
            documentId: userId,
          );
          if (userData != null) {
            final statusStr = interest[FirebaseConstants.fieldStatus] as String?;
            InterestStatus status = InterestStatus.sent;
            if (statusStr == FirebaseConstants.statusAccepted) {
              status = InterestStatus.accepted;
            } else if (statusStr == FirebaseConstants.statusRejected) {
              status = InterestStatus.rejected;
            }

            matches.add(MatchModel.fromFirestore(userData).copyWith(
              interestStatus: status,
              interestId: interest['id'] as String?,
            ));
          }
        }
      }
      return matches;
    });
  }

  /// Stream newly joined users (real-time)
  Stream<List<MatchModel>> streamNewlyJoined({int limit = 10}) {
    if (!useFirebase) return Stream.value([]);

    return firestoreService.queryStream(
      collection: FirebaseConstants.usersCollection,
      orderBy: FirebaseConstants.fieldCreatedAt,
      descending: true,
      limit: limit,
    ).asyncMap((users) async {
      final matches = users
          .where((data) => data['id'] != currentUserId)
          .map((data) => MatchModel.fromFirestore(data))
          .toList();
      return await _enrichMatchesWithStatus(matches);
    });
  }

  // ==================== INTERESTS ====================

  /// Send interest to a match
  Future<bool> sendInterest(String matchId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(
          interestStatus: InterestStatus.sent,
        );
      }
      return true;
    }

    if (currentUserId == null) return false;

    await firestoreService.create(
      collection: FirebaseConstants.interestsCollection,
      data: {
        FirebaseConstants.fieldFromUserId: currentUserId,
        FirebaseConstants.fieldToUserId: matchId,
        FirebaseConstants.fieldStatus: FirebaseConstants.statusPending,
      },
    );

    return true;
  }

  /// Accept interest
  Future<bool> acceptInterest(String interestId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    await firestoreService.update(
      collection: FirebaseConstants.interestsCollection,
      documentId: interestId,
      data: {
        FirebaseConstants.fieldStatus: FirebaseConstants.statusAccepted,
      },
    );

    return true;
  }

  /// Reject interest
  Future<bool> rejectInterest(String interestId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    await firestoreService.update(
      collection: FirebaseConstants.interestsCollection,
      documentId: interestId,
      data: {
        FirebaseConstants.fieldStatus: FirebaseConstants.statusRejected,
      },
    );

    return true;
  }

  /// Get sent interests
  Future<PaginatedResponse<MatchModel>> getSentInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.sent,
      );
    }

    if (currentUserId == null) {
      return PaginatedResponse(items: [], pagination: PaginationMeta.empty());
    }

    final interests = await firestoreService.getWhere(
      collection: FirebaseConstants.interestsCollection,
      field: FirebaseConstants.fieldFromUserId,
      isEqualTo: currentUserId,
      limit: perPage,
    );

    final userIds = interests
        .map((i) => i[FirebaseConstants.fieldToUserId] as String?)
        .whereType<String>()
        .toList();

    final matches = <MatchModel>[];
    for (final userId in userIds) {
      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      if (userData != null) {
        matches.add(MatchModel.fromFirestore(userData).copyWith(
          interestStatus: InterestStatus.sent,
        ));
      }
    }

    return PaginatedResponse(
      items: matches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: matches.length,
        hasMorePages: false,
      ),
    );
  }

  /// Get received interests
  Future<PaginatedResponse<MatchModel>> getReceivedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.received,
      );
    }

    if (currentUserId == null) {
      return PaginatedResponse(items: [], pagination: PaginationMeta.empty());
    }

    final interests = await firestoreService.query(
      collection: FirebaseConstants.interestsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldToUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldStatus,
          operator: QueryOperator.isEqualTo,
          value: FirebaseConstants.statusPending,
        ),
      ],
      limit: perPage,
    );

    final matches = <MatchModel>[];
    for (final interest in interests) {
      final userId = interest[FirebaseConstants.fieldFromUserId] as String?;
      if (userId != null) {
        final userData = await firestoreService.getById(
          collection: FirebaseConstants.usersCollection,
          documentId: userId,
        );
        if (userData != null) {
          matches.add(MatchModel.fromFirestore(userData).copyWith(
            interestStatus: InterestStatus.received,
            interestId: interest['id'] as String?,
          ));
        }
      }
    }

    return PaginatedResponse(
      items: matches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: matches.length,
        hasMorePages: false,
      ),
    );
  }

  /// Get accepted connections
  Future<PaginatedResponse<MatchModel>> getAcceptedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(
        page: page,
        perPage: perPage,
        interestStatus: InterestStatus.accepted,
      );
    }

    if (currentUserId == null) {
      return PaginatedResponse(items: [], pagination: PaginationMeta.empty());
    }

    // Get interests where current user sent and was accepted
    final sentAccepted = await firestoreService.query(
      collection: FirebaseConstants.interestsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldFromUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldStatus,
          operator: QueryOperator.isEqualTo,
          value: FirebaseConstants.statusAccepted,
        ),
      ],
    );

    // Get interests where current user received and accepted
    final receivedAccepted = await firestoreService.query(
      collection: FirebaseConstants.interestsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldToUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldStatus,
          operator: QueryOperator.isEqualTo,
          value: FirebaseConstants.statusAccepted,
        ),
      ],
    );

    final userIds = <String>{};
    for (final interest in sentAccepted) {
      final id = interest[FirebaseConstants.fieldToUserId] as String?;
      if (id != null) userIds.add(id);
    }
    for (final interest in receivedAccepted) {
      final id = interest[FirebaseConstants.fieldFromUserId] as String?;
      if (id != null) userIds.add(id);
    }

    final matches = <MatchModel>[];
    for (final userId in userIds.take(perPage)) {
      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      if (userData != null) {
        matches.add(MatchModel.fromFirestore(userData).copyWith(
          interestStatus: InterestStatus.accepted,
        ));
      }
    }

    return PaginatedResponse(
      items: matches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: matches.length,
        hasMorePages: false,
      ),
    );
  }

  // ==================== SHORTLIST ====================

  /// Add to shortlist
  Future<bool> addToShortlist(String matchId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(isShortlisted: true);
      }
      return true;
    }

    if (currentUserId == null) return false;

    await firestoreService.create(
      collection: FirebaseConstants.shortlistsCollection,
      data: {
        FirebaseConstants.fieldUserId: currentUserId,
        FirebaseConstants.fieldSavedUserId: matchId,
      },
    );

    return true;
  }

  /// Remove from shortlist
  Future<bool> removeFromShortlist(String matchId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMatches.indexWhere((m) => m.id == matchId);
      if (index != -1) {
        _mockMatches[index] = _mockMatches[index].copyWith(isShortlisted: false);
      }
      return true;
    }

    if (currentUserId == null) return false;

    // Find and delete the shortlist entry
    final shortlists = await firestoreService.query(
      collection: FirebaseConstants.shortlistsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldUserId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
        ),
        QueryFilter(
          field: FirebaseConstants.fieldSavedUserId,
          operator: QueryOperator.isEqualTo,
          value: matchId,
        ),
      ],
    );

    for (final shortlist in shortlists) {
      await firestoreService.delete(
        collection: FirebaseConstants.shortlistsCollection,
        documentId: shortlist['id'] as String,
      );
    }

    return true;
  }

  /// Get shortlisted matches
  Future<PaginatedResponse<MatchModel>> getShortlistedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(page: page, perPage: perPage, shortlistedOnly: true);
    }

    if (currentUserId == null) {
      return PaginatedResponse(items: [], pagination: PaginationMeta.empty());
    }

    final shortlists = await firestoreService.getWhere(
      collection: FirebaseConstants.shortlistsCollection,
      field: FirebaseConstants.fieldUserId,
      isEqualTo: currentUserId,
      limit: perPage,
    );

    final matches = <MatchModel>[];
    for (final shortlist in shortlists) {
      final userId = shortlist[FirebaseConstants.fieldSavedUserId] as String?;
      if (userId != null) {
        final userData = await firestoreService.getById(
          collection: FirebaseConstants.usersCollection,
          documentId: userId,
        );
        if (userData != null) {
          matches.add(MatchModel.fromFirestore(userData).copyWith(
            isShortlisted: true,
          ));
        }
      }
    }

    return PaginatedResponse(
      items: matches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: matches.length,
        hasMorePages: false,
      ),
    );
  }

  // ==================== PROFILE VIEWS ====================

  /// Record profile view
  Future<void> recordProfileView(String matchId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    if (currentUserId == null || currentUserId == matchId) return;

    await firestoreService.create(
      collection: FirebaseConstants.profileViewsCollection,
      data: {
        FirebaseConstants.fieldViewerId: currentUserId,
        FirebaseConstants.fieldViewedUserId: matchId,
        FirebaseConstants.fieldViewedAt: firestoreService.serverTimestamp,
      },
    );
  }

  /// Get who viewed me
  Future<PaginatedResponse<MatchModel>> getWhoViewedMe({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!useFirebase) {
      return _getMockMatches(page: page, perPage: perPage);
    }

    if (currentUserId == null) {
      return PaginatedResponse(items: [], pagination: PaginationMeta.empty());
    }

    final views = await firestoreService.getWhere(
      collection: FirebaseConstants.profileViewsCollection,
      field: FirebaseConstants.fieldViewedUserId,
      isEqualTo: currentUserId,
      limit: perPage,
      orderBy: FirebaseConstants.fieldViewedAt,
      descending: true,
    );

    final viewerIds = views
        .map((v) => v[FirebaseConstants.fieldViewerId] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final matches = <MatchModel>[];
    for (final userId in viewerIds) {
      final userData = await firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      if (userData != null) {
        matches.add(MatchModel.fromFirestore(userData));
      }
    }

    return PaginatedResponse(
      items: matches,
      pagination: PaginationMeta(
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: matches.length,
        hasMorePages: false,
      ),
    );
  }

  // ==================== BLOCK & REPORT ====================

  /// Block user
  Future<bool> blockUser(String userId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    if (currentUserId == null) return false;

    await firestoreService.create(
      collection: FirebaseConstants.blocksCollection,
      data: {
        FirebaseConstants.fieldBlockerId: currentUserId,
        FirebaseConstants.fieldBlockedUserId: userId,
      },
    );

    return true;
  }

  /// Unblock user
  Future<bool> unblockUser(String userId) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    if (currentUserId == null) return false;

    final blocks = await firestoreService.query(
      collection: FirebaseConstants.blocksCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldBlockerId,
          operator: QueryOperator.isEqualTo,
          value: currentUserId,
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
        documentId: block['id'] as String,
      );
    }

    return true;
  }

  /// Report user
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    if (!useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }

    if (currentUserId == null) return false;

    await firestoreService.create(
      collection: FirebaseConstants.reportsCollection,
      data: {
        FirebaseConstants.fieldReporterId: currentUserId,
        FirebaseConstants.fieldReportedUserId: userId,
        FirebaseConstants.fieldReason: reason,
        FirebaseConstants.fieldDescription: description,
        FirebaseConstants.fieldStatus: FirebaseConstants.reportStatusPending,
      },
    );

    return true;
  }

  // ==================== HELPER METHODS ====================

  /// Enrich matches with shortlist and interest status
  Future<List<MatchModel>> _enrichMatchesWithStatus(List<MatchModel> matches) async {
    if (currentUserId == null || matches.isEmpty) return matches;

    // Get shortlisted users
    final shortlists = await firestoreService.getWhere(
      collection: FirebaseConstants.shortlistsCollection,
      field: FirebaseConstants.fieldUserId,
      isEqualTo: currentUserId,
    );
    final shortlistedIds = shortlists
        .map((s) => s[FirebaseConstants.fieldSavedUserId] as String?)
        .whereType<String>()
        .toSet();

    // Get sent interests
    final sentInterests = await firestoreService.getWhere(
      collection: FirebaseConstants.interestsCollection,
      field: FirebaseConstants.fieldFromUserId,
      isEqualTo: currentUserId,
    );
    final sentInterestMap = <String, Map<String, dynamic>>{};
    for (final interest in sentInterests) {
      final toId = interest[FirebaseConstants.fieldToUserId] as String?;
      if (toId != null) sentInterestMap[toId] = interest;
    }

    // Get received interests
    final receivedInterests = await firestoreService.getWhere(
      collection: FirebaseConstants.interestsCollection,
      field: FirebaseConstants.fieldToUserId,
      isEqualTo: currentUserId,
    );
    final receivedInterestMap = <String, Map<String, dynamic>>{};
    for (final interest in receivedInterests) {
      final fromId = interest[FirebaseConstants.fieldFromUserId] as String?;
      if (fromId != null) receivedInterestMap[fromId] = interest;
    }

    return matches.map((match) {
      InterestStatus status = InterestStatus.none;
      String? interestId;

      if (sentInterestMap.containsKey(match.id)) {
        final interest = sentInterestMap[match.id]!;
        final statusStr = interest[FirebaseConstants.fieldStatus] as String?;
        if (statusStr == FirebaseConstants.statusAccepted) {
          status = InterestStatus.accepted;
        } else if (statusStr == FirebaseConstants.statusRejected) {
          status = InterestStatus.rejected;
        } else {
          status = InterestStatus.sent;
        }
        interestId = interest['id'] as String?;
      } else if (receivedInterestMap.containsKey(match.id)) {
        final interest = receivedInterestMap[match.id]!;
        final statusStr = interest[FirebaseConstants.fieldStatus] as String?;
        if (statusStr == FirebaseConstants.statusAccepted) {
          status = InterestStatus.accepted;
        } else if (statusStr == FirebaseConstants.statusRejected) {
          status = InterestStatus.rejected;
        } else {
          status = InterestStatus.received;
        }
        interestId = interest['id'] as String?;
      }

      return match.copyWith(
        isShortlisted: shortlistedIds.contains(match.id),
        interestStatus: status,
        interestId: interestId,
      );
    }).toList();
  }

  /// Apply filters that can't be done in Firestore query
  List<MatchModel> _applyLocalFilters(List<MatchModel> matches, MatchFilter filter) {
    return matches.where((m) {
      // Age filter
      if (filter.minAge != null && (m.age ?? 0) < filter.minAge!) return false;
      if (filter.maxAge != null && (m.age ?? 100) > filter.maxAge!) return false;

      // Height filter
      if (filter.minHeight != null && (m.height ?? 0) < filter.minHeight!) return false;
      if (filter.maxHeight != null && (m.height ?? 300) > filter.maxHeight!) return false;

      // With photo only
      if (filter.withPhotoOnly == true && m.profilePhoto == null) return false;

      // Online only
      if (filter.onlineOnly == true && !m.isOnline) return false;

      return true;
    }).toList();
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
      matches = _applyLocalFilters(matches, filter);
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
}
