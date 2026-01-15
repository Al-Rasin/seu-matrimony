import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class MatchRepository {
  final DioClient _dioClient = Get.find<DioClient>();

  Future<Map<String, dynamic>> getMatches({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (filters != null) ...filters,
      };

      final response = await _dioClient.get(
        ApiConstants.matches,
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecommendedMatches() async {
    try {
      final response = await _dioClient.get(ApiConstants.recommendedMatches);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getNewlyJoined() async {
    try {
      final response = await _dioClient.get(ApiConstants.newlyJoined);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchMatches(
      Map<String, dynamic> filters) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.searchMatches,
        queryParameters: filters,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordProfileView(String userId) async {
    try {
      await _dioClient.post('${ApiConstants.profileViews}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWhoViewedMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.whoViewedMe);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getViewedByMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.viewedByMe);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToShortlist(String userId) async {
    try {
      await _dioClient.post('${ApiConstants.shortlist}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromShortlist(String userId) async {
    try {
      await _dioClient.delete('${ApiConstants.shortlist}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyShortlist() async {
    try {
      final response = await _dioClient.get(ApiConstants.shortlist);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getShortlistedMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.shortlistedMe);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
