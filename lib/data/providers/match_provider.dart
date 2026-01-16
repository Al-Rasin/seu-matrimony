import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/network/api_response.dart';
import '../models/match_model.dart';

/// Match provider for handling match-related API calls
class MatchProvider extends ApiService {
  // ==================== MATCHES ====================

  /// Get all matches with optional filters (paginated)
  Future<PaginatedResponse<MatchModel>> getMatches({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? filters,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.matches,
      page: page,
      perPage: perPage,
      queryParameters: filters,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get recommended matches for current user
  Future<PaginatedResponse<MatchModel>> getRecommendedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.recommendedMatches,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get newly joined users
  Future<PaginatedResponse<MatchModel>> getNewlyJoined({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.newlyJoined,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Search matches by query
  Future<PaginatedResponse<MatchModel>> searchMatches({
    required String query,
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? filters,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.searchMatches,
      page: page,
      perPage: perPage,
      queryParameters: {
        'q': query,
        ...?filters,
      },
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get match profile details by ID
  Future<ApiResponse<MatchModel>> getMatchProfile(String matchId) async {
    return get<MatchModel>(
      '${ApiConstants.matches}/$matchId',
      fromJson: (data) => MatchModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==================== INTERESTS ====================

  /// Send interest to a match
  Future<ApiResponse<void>> sendInterest(String matchId) async {
    return post(
      ApiConstants.interests,
      data: {'to_user_id': matchId},
    );
  }

  /// Accept interest from a match
  Future<ApiResponse<void>> acceptInterest(String interestId) async {
    return patch(
      '${ApiConstants.interests}/$interestId/accept',
    );
  }

  /// Reject interest from a match
  Future<ApiResponse<void>> rejectInterest(String interestId) async {
    return patch(
      '${ApiConstants.interests}/$interestId/reject',
    );
  }

  /// Cancel sent interest
  Future<ApiResponse<void>> cancelInterest(String interestId) async {
    return delete(
      '${ApiConstants.interests}/$interestId',
    );
  }

  /// Get sent interests (paginated)
  Future<PaginatedResponse<MatchModel>> getSentInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.sentInterests,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get received interests (paginated)
  Future<PaginatedResponse<MatchModel>> getReceivedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.receivedInterests,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get accepted interests/connections (paginated)
  Future<PaginatedResponse<MatchModel>> getAcceptedInterests({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.interests,
      page: page,
      perPage: perPage,
      queryParameters: {'status': 'accepted'},
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  // ==================== SHORTLIST ====================

  /// Add match to shortlist
  Future<ApiResponse<void>> addToShortlist(String matchId) async {
    return post(
      ApiConstants.shortlist,
      data: {'user_id': matchId},
    );
  }

  /// Remove match from shortlist
  Future<ApiResponse<void>> removeFromShortlist(String matchId) async {
    return delete(
      '${ApiConstants.shortlist}/$matchId',
    );
  }

  /// Get shortlisted matches (paginated)
  Future<PaginatedResponse<MatchModel>> getShortlistedMatches({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.shortlist,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get users who shortlisted me (paginated)
  Future<PaginatedResponse<MatchModel>> getShortlistedByMe({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.shortlistedMe,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  // ==================== PROFILE VIEWS ====================

  /// Record profile view (called when viewing a match's profile)
  Future<ApiResponse<void>> recordProfileView(String matchId) async {
    return post(
      ApiConstants.profileViews,
      data: {'viewed_user_id': matchId},
    );
  }

  /// Get users who viewed my profile (paginated)
  Future<PaginatedResponse<MatchModel>> getWhoViewedMe({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.whoViewedMe,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  /// Get profiles I viewed (paginated)
  Future<PaginatedResponse<MatchModel>> getViewedByMe({
    int page = 1,
    int perPage = 10,
  }) async {
    return getPaginated<MatchModel>(
      ApiConstants.viewedByMe,
      page: page,
      perPage: perPage,
      fromJson: (json) => MatchModel.fromJson(json),
    );
  }

  // ==================== BLOCK & REPORT ====================

  /// Block a user
  Future<ApiResponse<void>> blockUser(String userId) async {
    return post(
      ApiConstants.block,
      data: {'user_id': userId},
    );
  }

  /// Unblock a user
  Future<ApiResponse<void>> unblockUser(String userId) async {
    return delete(
      '${ApiConstants.block}/$userId',
    );
  }

  /// Report a user
  Future<ApiResponse<void>> reportUser({
    required String userId,
    required String reason,
    String? description,
  }) async {
    return post(
      ApiConstants.report,
      data: {
        'user_id': userId,
        'reason': reason,
        if (description != null) 'description': description,
      },
    );
  }
}
