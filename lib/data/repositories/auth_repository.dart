import 'dart:convert';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/mock_data_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final StorageService _storageService;
  final MockDataService _mockDataService;
  AuthService? _authService;

  AuthRepository({
    StorageService? storageService,
    MockDataService? mockDataService,
    AuthService? authService,
  })  : _storageService = storageService ?? Get.find<StorageService>(),
        _mockDataService = mockDataService ?? Get.find<MockDataService>(),
        _authService = authService;

  AuthService get authService {
    _authService ??= Get.find<AuthService>();
    return _authService!;
  }

  /// Current logged in user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Check if using Firebase or mock data
  bool get useFirebase => !MockDataService.useMockData;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Use Firebase Auth
    if (useFirebase) {
      final result = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Login failed');
      }

      // Convert Firebase user data to UserModel
      if (result.userData != null) {
        _currentUser = UserModel.fromFirestore(result.userData!);
        await _storageService.saveUserData(jsonEncode(_currentUser!.toJson()));
      }

      _storageService.isLoggedIn = true;
      return _currentUser!;
    }

    // Use mock data for development
    final mockResult = await _mockDataService.login(email, password);

    if (!mockResult.success) {
      throw Exception(mockResult.errorMessage ?? 'Login failed');
    }

    // Save auth data
    _storageService.isLoggedIn = true;
    _storageService.accessToken = mockResult.accessToken;
    _storageService.refreshToken = mockResult.refreshToken;

    // Save user data
    if (mockResult.user != null) {
      _currentUser = mockResult.user;
      await _storageService.saveUserData(jsonEncode(mockResult.user!.toJson()));
    }

    return mockResult.user!;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String profileFor,
    String? idDocumentBase64,
  }) async {
    // Use Firebase Auth
    if (useFirebase) {
      final result = await authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        profileFor: profileFor,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Registration failed');
      }

      // If we have ID document, update user profile
      if (idDocumentBase64 != null && result.user != null) {
        await authService.updateUserData({
          'seuIdDocument': idDocumentBase64,
        });
      }

      // Fetch user data
      final userData = await authService.getCurrentUserData();
      if (userData != null) {
        _currentUser = UserModel.fromFirestore(userData);
        await _storageService.saveUserData(jsonEncode(_currentUser!.toJson()));
      }

      _storageService.isLoggedIn = true;
      return _currentUser!;
    }

    // Use mock data for development
    final mockResult = await _mockDataService.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      profileFor: profileFor,
    );

    if (!mockResult.success) {
      throw Exception(mockResult.errorMessage ?? 'Registration failed');
    }

    // Save auth data
    _storageService.isLoggedIn = true;
    _storageService.accessToken = mockResult.accessToken;
    _storageService.refreshToken = mockResult.refreshToken;

    // Save user data
    if (mockResult.user != null) {
      _currentUser = mockResult.user;
      await _storageService.saveUserData(jsonEncode(mockResult.user!.toJson()));
    }

    return mockResult.user!;
  }

  Future<void> logout() async {
    if (useFirebase) {
      await authService.signOut();
    }
    _currentUser = null;
    await _storageService.clearAuthData();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (useFirebase) {
      final result = await authService.sendPasswordResetEmail(email);
      if (!result.success) {
        throw Exception(result.error ?? 'Failed to send reset email');
      }
      return;
    }

    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    final exists = await _mockDataService.emailExists(email);
    if (!exists) {
      throw Exception('No account found with this email');
    }
  }

  /// Verify OTP for phone authentication
  Future<void> verifyOtp(String verificationId, String otp) async {
    if (useFirebase) {
      final result = await authService.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: otp,
      );
      if (!result.success) {
        throw Exception(result.error ?? 'OTP verification failed');
      }
      return;
    }

    // Mock implementation - just simulate success
    await Future.delayed(const Duration(seconds: 1));
  }

  bool get isLoggedIn {
    if (useFirebase) {
      return authService.isLoggedIn;
    }
    return _storageService.isLoggedIn;
  }

  String? get currentUserId {
    if (useFirebase) {
      return authService.currentUserId;
    }
    return _storageService.userId;
  }

  /// Load saved user from storage
  Future<UserModel?> loadSavedUser() async {
    if (useFirebase) {
      final userData = await authService.getCurrentUserData();
      if (userData != null) {
        _currentUser = UserModel.fromFirestore(userData);
        return _currentUser;
      }
      return null;
    }

    final userData = await _storageService.getUserData();
    if (userData != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userData));
      return _currentUser;
    }
    return null;
  }

  /// Update user profile data
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (useFirebase) {
      await authService.updateUserData(data);
      // Refresh current user
      final userData = await authService.getCurrentUserData();
      if (userData != null) {
        _currentUser = UserModel.fromFirestore(userData);
      }
      return;
    }

    // Mock - just update local cache
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get user role (for admin check)
  Future<String?> getUserRole() async {
    if (useFirebase) {
      return await authService.getUserRole();
    }
    return _storageService.userRole;
  }

  /// Check if profile is complete
  Future<bool> isProfileComplete() async {
    if (useFirebase) {
      return await authService.isProfileComplete();
    }
    return _storageService.isProfileComplete;
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    if (useFirebase) {
      return await authService.isEmailVerified();
    }
    return true; // Mock: always verified
  }
}
