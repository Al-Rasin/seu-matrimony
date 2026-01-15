import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class InterestRepository {
  final DioClient _dioClient = Get.find<DioClient>();

  Future<Map<String, dynamic>> sendInterest(String userId) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.interests,
        data: {'receiverId': userId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSentInterests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.sentInterests,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReceivedInterests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.receivedInterests,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptInterest(String interestId) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.interests}/$interestId/accept',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectInterest(String interestId) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.interests}/$interestId/reject',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
