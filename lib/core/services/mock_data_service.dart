import 'package:get/get.dart';
import '../../data/models/user_model.dart';

/// Mock data service for development without backend
class MockDataService extends GetxService {
  /// Flag to enable/disable mock mode
  static const bool useMockData = false;

  /// Mock users database
  final Map<String, MockUser> _mockUsers = {
    'alrasin500@gmail.com': MockUser(
      email: 'alrasin500@gmail.com',
      password: '12345678',
      user: UserModel(
        id: 'user_001',
        username: 'alrasin500',
        fullName: 'Al Rasin',
        email: 'alrasin500@gmail.com',
        phone: '+8801712345678',
        gender: 'male',
        dateOfBirth: DateTime(1995, 5, 15),
        role: UserRole.user,
        profileStatus: ProfileStatus.active,
        isVerified: true,
        profileCompletionPercentage: 85,
        department: 'Computer Science & Engineering',
        studentId: 'CSE-2015-001',
        isCurrentlyStudying: false,
        maritalStatus: 'never_married',
        height: 175.0,
        religion: 'Islam',
        highestEducation: 'Bachelor\'s Degree',
        educationDetails: 'BSc in CSE from Southeast University',
        employmentType: 'full_time',
        occupation: 'Software Engineer',
        annualIncome: '10-15 LPA',
        workLocation: 'Dhaka',
        companyName: 'Tech Solutions Ltd',
        currentCity: 'Dhaka',
        bio: 'A passionate software engineer looking for a life partner who shares similar values and aspirations.',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime.now(),
      ),
    ),
  };

  /// Authenticate user with email and password
  Future<MockAuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final mockUser = _mockUsers[email.toLowerCase()];

    if (mockUser == null) {
      return MockAuthResult(
        success: false,
        errorMessage: 'User not found with this email',
      );
    }

    if (mockUser.password != password) {
      return MockAuthResult(
        success: false,
        errorMessage: 'Invalid password',
      );
    }

    return MockAuthResult(
      success: true,
      user: mockUser.user,
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Register a new user
  Future<MockAuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String profileFor,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.containsKey(email.toLowerCase())) {
      return MockAuthResult(
        success: false,
        errorMessage: 'Email already registered',
      );
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: email.split('@').first,
      fullName: fullName,
      email: email,
      phone: phone,
      role: UserRole.user,
      profileStatus: ProfileStatus.pending,
      isVerified: false,
      profileCompletionPercentage: 20,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockUsers[email.toLowerCase()] = MockUser(
      email: email,
      password: password,
      user: newUser,
    );

    return MockAuthResult(
      success: true,
      user: newUser,
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockUsers.containsKey(email.toLowerCase());
  }

  /// Get user by email
  UserModel? getUserByEmail(String email) {
    return _mockUsers[email.toLowerCase()]?.user;
  }
}

/// Mock user data class
class MockUser {
  final String email;
  final String password;
  final UserModel user;

  MockUser({
    required this.email,
    required this.password,
    required this.user,
  });
}

/// Mock auth result
class MockAuthResult {
  final bool success;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  MockAuthResult({
    required this.success,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });
}
