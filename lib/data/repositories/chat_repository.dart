import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class ChatRepository {
  final DioClient _dioClient = Get.find<DioClient>();

  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.conversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.conversations}/$conversationId',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createConversation(String userId) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.conversations,
        data: {'participantId': userId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.conversations}/$conversationId/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content, {
    String type = 'text',
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.conversations}/$conversationId/messages',
        data: {'content': content, 'type': type},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _dioClient.put(
        '${ApiConstants.conversations}/$conversationId/read',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _dioClient.post('${ApiConstants.block}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _dioClient.delete('${ApiConstants.block}/$userId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportUser(String userId, String reason, String description) async {
    try {
      await _dioClient.post(
        ApiConstants.report,
        data: {
          'reportedUserId': userId,
          'reason': reason,
          'description': description,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
