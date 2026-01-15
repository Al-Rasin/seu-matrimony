import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class UserRepository {
  final DioClient _dioClient = Get.find<DioClient>();

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.currentUser);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dioClient.get('${ApiConstants.userById}/$userId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBasicDetails(
      Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updateBasicDetails,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePersonalDetails(
      Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updatePersonalDetails,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfessionalDetails(
      Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updateProfessionalDetails,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateFamilyDetails(
      Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updateFamilyDetails,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.updatePreferences,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dioClient.get(ApiConstants.dashboardStats);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getProfileCompletion() async {
    try {
      final response = await _dioClient.get(ApiConstants.profileCompletion);
      return response.data['percentage'] ?? 0;
    } catch (e) {
      rethrow;
    }
  }
}
