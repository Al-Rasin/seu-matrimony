import 'package:get/get.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';
import 'dart:convert';

class UserRepository {
  final StorageService _storageService = Get.find<StorageService>();

  Future<Map<String, dynamic>> getCurrentUser() async {
    if (MockDataService.useMockData) {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        return jsonDecode(userData);
      }
      // Return default mock user data
      return {
        'id': 'user_001',
        'fullName': 'Al Rasin',
        'email': 'alrasin500@gmail.com',
        'phone': '+8801712345678',
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'id': userId,
        'fullName': 'Mock User',
        'email': 'mockuser@example.com',
      };
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> updateBasicDetails(
      Map<String, dynamic> data) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, ...data};
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> updatePersonalDetails(
      Map<String, dynamic> data) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, ...data};
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> updateProfessionalDetails(
      Map<String, dynamic> data) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, ...data};
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> updateFamilyDetails(
      Map<String, dynamic> data) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, ...data};
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> data) async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, ...data};
    }
    throw Exception('Backend not available');
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    if (MockDataService.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'profileViews': 156,
        'sentInterests': 23,
        'receivedInterests': 45,
        'acceptedProfiles': 12,
      };
    }
    throw Exception('Backend not available');
  }

  Future<int> getProfileCompletion() async {
    if (MockDataService.useMockData) {
      final userData = await _storageService.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(jsonDecode(userData));
        return user.profileCompletionPercentage;
      }
      return 85;
    }
    throw Exception('Backend not available');
  }
}
