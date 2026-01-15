import 'dart:convert';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/mock_data_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final StorageService _storageService = Get.find<StorageService>();
  final MockDataService _mockDataService = Get.find<MockDataService>();

  /// Current logged in user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Use mock data for development
    if (MockDataService.useMockData) {
      final result = await _mockDataService.login(email, password);

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Login failed');
      }

      // Save auth data
      _storageService.isLoggedIn = true;
      _storageService.accessToken = result.accessToken;
      _storageService.refreshToken = result.refreshToken;

      // Save user data
      if (result.user != null) {
        _currentUser = result.user;
        await _storageService.saveUserData(jsonEncode(result.user!.toJson()));
      }

      return result.user!;
    }

    // Real API implementation would go here
    throw Exception('Backend not available');
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String profileFor,
    String? idDocumentUrl,
  }) async {
    // Use mock data for development
    if (MockDataService.useMockData) {
      final result = await _mockDataService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        profileFor: profileFor,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Registration failed');
      }

      // Save auth data
      _storageService.isLoggedIn = true;
      _storageService.accessToken = result.accessToken;
      _storageService.refreshToken = result.refreshToken;

      // Save user data
      if (result.user != null) {
        _currentUser = result.user;
        await _storageService.saveUserData(jsonEncode(result.user!.toJson()));
      }

      return result.user!;
    }

    // Real API implementation would go here
    throw Exception('Backend not available');
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearAuthData();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (MockDataService.useMockData) {
      // Simulate sending reset email
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists
      final exists = await _mockDataService.emailExists(email);
      if (!exists) {
        throw Exception('No account found with this email');
      }
      return;
    }

    throw Exception('Backend not available');
  }

  bool get isLoggedIn => _storageService.isLoggedIn;

  /// Load saved user from storage
  Future<UserModel?> loadSavedUser() async {
    final userData = await _storageService.getUserData();
    if (userData != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userData));
      return _currentUser;
    }
    return null;
  }
}
